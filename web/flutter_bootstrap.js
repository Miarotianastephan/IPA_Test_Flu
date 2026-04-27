{{flutter_js}}
{{flutter_build_config}}

async function installMiniTexForCanvasKit() {
  if (window.__useMiniTex === false) {
    document.documentElement.dataset.minitex = "skipped-ios-safari";
    return;
  }

  const miniTexInstaller = window.MiniTex?.MiniTex?.install ?? window.MiniTex?.install;
  if (!miniTexInstaller || !window.flutterCanvasKitLoaded) {
    return;
  }

  const canvasKit = await window.flutterCanvasKitLoaded;
  if (!canvasKit || canvasKit.__miniTexInstalled) {
    return;
  }

  const embeddingFonts = await fetchEmbeddingFontFamilies();
  miniTexInstaller(
    canvasKit,
    window.devicePixelRatio || 1,
    embeddingFonts
  );
  installMiniTexEmojiBridge(canvasKit);
  canvasKit.__miniTexInstalled = true;
  document.documentElement.dataset.minitex = "installed";
}

const miniTexEmojiRegex =
  /(?:[\u{1F1E6}-\u{1F1FF}]{2}|[#*0-9]\uFE0F?\u20E3|[\u{1F000}-\u{1FAFF}\u2600-\u27BF](?:[\uFE00-\uFE0F]|\u{1F3FB}-\u{1F3FF})?(?:\u200D[\u{1F000}-\u{1FAFF}\u2600-\u27BF](?:[\uFE00-\uFE0F]|\u{1F3FB}-\u{1F3FF})?)*)/gu;

function installMiniTexEmojiBridge(canvasKit) {
  if (canvasKit.__miniTexEmojiBridgeInstalled) {
    return;
  }

  const firstPrivateCodePoint = 0xE000;
  const lastPrivateCodePoint = 0xF8FF;
  let nextPrivateCodePoint = firstPrivateCodePoint;
  const emojiToPrivateChar = new Map();
  const privateCharToEmoji = new Map();

  const encodeEmoji = (text) => String(text).replace(miniTexEmojiRegex, (emoji) => {
    let privateChar = emojiToPrivateChar.get(emoji);
    if (!privateChar) {
      if (nextPrivateCodePoint > lastPrivateCodePoint) {
        return emoji;
      }
      privateChar = String.fromCharCode(nextPrivateCodePoint++);
      emojiToPrivateChar.set(emoji, privateChar);
      privateCharToEmoji.set(privateChar, emoji);
    }
    return privateChar;
  });

  const decodeEmoji = (text) => String(text).replace(/[\uE000-\uF8FF]/g, (privateChar) => {
    return privateCharToEmoji.get(privateChar) ?? privateChar;
  });

  patchCanvasTextApi(decodeEmoji);
  patchMiniTexParagraphBuilder(canvasKit, encodeEmoji);
  canvasKit.__miniTexEmojiBridgeInstalled = true;
}

function patchCanvasTextApi(decodeEmoji) {
  if (
    typeof CanvasRenderingContext2D === "undefined" ||
    CanvasRenderingContext2D.prototype.__miniTexEmojiBridgePatched
  ) {
    return;
  }

  const contextPrototype = CanvasRenderingContext2D.prototype;
  const originalMeasureText = contextPrototype.measureText;
  const originalFillText = contextPrototype.fillText;
  const originalStrokeText = contextPrototype.strokeText;

  contextPrototype.measureText = function(text) {
    return originalMeasureText.call(this, decodeEmoji(text));
  };

  contextPrototype.fillText = function(text, x, y, maxWidth) {
    const decodedText = decodeEmoji(text);
    if (maxWidth === undefined) {
      return originalFillText.call(this, decodedText, x, y);
    }
    return originalFillText.call(this, decodedText, x, y, maxWidth);
  };

  contextPrototype.strokeText = function(text, x, y, maxWidth) {
    const decodedText = decodeEmoji(text);
    if (maxWidth === undefined) {
      return originalStrokeText.call(this, decodedText, x, y);
    }
    return originalStrokeText.call(this, decodedText, x, y, maxWidth);
  };

  contextPrototype.__miniTexEmojiBridgePatched = true;
}

function patchMiniTexParagraphBuilder(canvasKit, encodeEmoji) {
  const originalMakeFromFontCollection =
    canvasKit.ParagraphBuilder.MakeFromFontCollection;

  canvasKit.ParagraphBuilder.MakeFromFontCollection = function(style, fontCollection) {
    const builder = originalMakeFromFontCollection.call(this, style, fontCollection);
    if (!builder?.isMiniTex || builder.__miniTexEmojiBridgePatched) {
      return builder;
    }

    const originalAddText = builder.addText;
    builder.addText = function(text) {
      return originalAddText.call(this, encodeEmoji(text));
    };
    builder.__miniTexEmojiBridgePatched = true;
    return builder;
  };
}

async function fetchEmbeddingFontFamilies() {
  return [
    "MaterialIcons"
  ];
}

const originalFetch = window.fetch.bind(window);
window.fetch = function(url, options) {
  const href = typeof url === "string" ? url : url?.url;
  if (
    window.__isPureIosSafari !== true &&
    href?.startsWith("https://fonts.gstatic.com/s/")
  ) {
    return Promise.resolve({
      ok: true,
      status: 200,
      statusText: "OK",
      headers: new Headers(),
      arrayBuffer: () => Promise.resolve(new ArrayBuffer(0)),
      text: () => Promise.resolve("")
    });
  }
  return originalFetch(url, options);
};

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}}
  },
  onEntrypointLoaded: async function(engineInitializer) {
    try {
      await installMiniTexForCanvasKit();
    } catch (error) {
      console.warn("MiniTex install failed; falling back to Flutter CanvasKit text.", error);
    }

    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
  }
});
