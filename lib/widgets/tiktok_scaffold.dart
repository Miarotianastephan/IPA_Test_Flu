import 'dart:math';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

const double scrollSpeed = 300;

enum TikTokPagePositon { left, right, middle, x }

class TikTokScaffoldController extends ValueNotifier<TikTokPagePositon> {
  TikTokScaffoldController([
    super.value = TikTokPagePositon.middle,
    bool enableGesture = true,
  ]) : _enableGesture = ValueNotifier(enableGesture);

  Future? animateToPage(TikTokPagePositon pagePositon) {
    return _onAnimateToPage?.call(pagePositon, 0);
  }

  Future? animateToLeft() {
    return _onAnimateToPage?.call(TikTokPagePositon.left, 0);
  }

  Future? animateToRight() {
    return _onAnimateToPage?.call(TikTokPagePositon.right, 0);
  }

  Future? animateToMiddle() {
    return _onAnimateToPage?.call(TikTokPagePositon.middle, 0);
  }

  Future? animateToX(double x) {
    if (!enableGesture) {
      return null;
    }
    return _onAnimateToPage?.call(TikTokPagePositon.x, x);
  }

  Future Function(TikTokPagePositon pagePositon, double x)? _onAnimateToPage;

  final ValueNotifier<bool> _enableGesture;
  bool? _tempGestureOriginal;

  ValueNotifier<bool> get enableGestureNotifier => _enableGesture;

  bool get enableGesture => _enableGesture.value;

  set enableGesture(bool val) => _enableGesture.value = val;
}

extension TikTokScaffoldControllerExtension on TikTokScaffoldController {
  Future<void> animateToRightWithTempGesture() async {
    if (!enableGesture) {
      _tempGestureOriginal = enableGesture; // 保存原始状态
      enableGesture = true; // 临时开启手势
    }

    await animateToRight(); // 执行动画
  }

  void restoreGestureIfNeeded(TikTokPagePositon pos) {
    if (pos == TikTokPagePositon.middle && _tempGestureOriginal != null) {
      enableGesture = _tempGestureOriginal!;
      _tempGestureOriginal = null;
    }
  }
}

class TikTokScaffold extends StatefulWidget {
  final TikTokScaffoldController? controller;

  /// 首页的顶部
  final Widget? header;

  /// 底部导航
  final Widget? tabBar;

  /// 左滑页面
  final Widget? leftPage;

  /// 右滑页面
  final Widget? rightPage;

  /// 视频序号
  final int currentIndex;

  final bool hasBottomPadding;

  final Widget? page;

  final Function()? onPullDownRefresh;

  const TikTokScaffold({
    super.key,
    this.header,
    this.tabBar,
    this.leftPage,
    this.rightPage,
    this.hasBottomPadding = false,
    this.page,
    this.currentIndex = 0,
    this.onPullDownRefresh,
    this.controller,
  });

  @override
  TikTokScaffoldState createState() => TikTokScaffoldState();
}

class TikTokScaffoldState extends State<TikTokScaffold>
    with TickerProviderStateMixin {
  AnimationController? animationControllerX;
  AnimationController? animationControllerY;
  late Animation<double> animationX;
  late Animation<double> animationY;
  double offsetX = 0.0;
  double offsetY = 0.0;

  // int currentIndex = 0;
  double inMiddle = 0;

  bool _enableGesture = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller!._onAnimateToPage = animateToPage;

      // 监听 controller 的 enableGesture
      _enableGesture = widget.controller?.enableGesture ?? true;
      widget.controller?.enableGestureNotifier.addListener(() {
        if (mounted) {
          setState(() {
            _enableGesture = widget.controller!.enableGesture;
          });
        }
      });
    });
  }

  Future animateToPage(p, x) async {
    switch (p) {
      case TikTokPagePositon.left:
        await animateTo(screenWidth);
        break;
      case TikTokPagePositon.middle:
        await animateTo();
        break;
      case TikTokPagePositon.right:
        await animateTo(-screenWidth);
        break;
      // case TikTokPagePositon.x:
      //   if (x < 0) {
      //     setState(() {
      //       offsetX += x;
      //       // clamp 到 [-screenWidth, 0]
      //       offsetX = offsetX.clamp(-screenWidth, 0);
      //     });
      //   }
      //   break;
      case TikTokPagePositon.x:
        setState(() {
          offsetX += x;
          offsetX = offsetX.clamp(-screenWidth, 0);
        });
        break;
    }
    widget.controller!.value = p;
    widget.controller!.restoreGestureIfNeeded(p);
  }

  double screenWidth = 0;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    // 先定义正常结构
    Widget body = Stack(
      children: <Widget>[
        // _LeftPageTransform(
        //   offsetX: offsetX,
        //   content: widget.leftPage,
        // ),
        VisibilityDetector(
          key: Key("middlePage"),
          onVisibilityChanged: (info) {
            debugPrint("Middle visible fraction = ${info.visibleFraction}");
          },
          child: Visibility(
            visible: offsetX > -screenWidth,
            maintainState: true,
            child: _MiddlePage(
              absorbing: absorbing,
              onTopDrag: () {
                // absorbing = true;
                setState(() {});
              },
              offsetX: offsetX,
              offsetY: offsetY,
              header: widget.header,
              tabBar: widget.tabBar,
              isStack: !widget.hasBottomPadding,
              page: widget.page,
            ),
          ),
        ),

        Visibility(
          visible: offsetX < 0, // 只有在滑出时才显示
          maintainState: true,
          child: _RightPageTransform(
            offsetX: offsetX,
            offsetY: offsetY,
            content: widget.rightPage,
          ),
        ),
      ],
    );
    // 增加手势控制
    body = GestureDetector(
      // onVerticalDragUpdate: calculateOffsetY,
      // onVerticalDragEnd: (_) async {
      //   if (!_enableGesture) return;
      //   absorbing = false;
      //   if (offsetY != 0) {
      //     await animateToTop();
      //     widget.onPullDownRefresh?.call();
      //     setState(() {});
      //   }
      // },
      onHorizontalDragEnd: (details) =>
          onHorizontalDragEnd(details, screenWidth),
      // 水平方向滑动开始
      onHorizontalDragStart: (_) {
        if (!_enableGesture) return;
        animationControllerX?.stop();
        animationControllerY?.stop();
      },
      onHorizontalDragUpdate: (details) =>
          onHorizontalDragUpdate(details, screenWidth),
      child: body,
    );
    body = PopScope(
      canPop: _enableGesture,
      onPopInvokedWithResult: (didPop, result) {
        if (!_enableGesture) return;
        if (inMiddle == 0) {
          return;
        }
        widget.controller!.animateToMiddle();
      },
      child: Scaffold(body: body, resizeToAvoidBottomInset: false),
    );
    return body;
  }

  //
  // // 水平方向滑动中
  // void onHorizontalDragUpdate(details, screenWidth) {
  //   if (!_enableGesture) return;
  //   // 控制 offsetX 的值在 -screenWidth 到 screenWidth 之间
  //   if (offsetX + details.delta.dx >= screenWidth) {
  //     setState(() {
  //       offsetX = screenWidth;
  //     });
  //   } else if (offsetX + details.delta.dx <= -screenWidth) {
  //     setState(() {
  //       offsetX = -screenWidth;
  //     });
  //   } else {
  //     setState(() {
  //       offsetX += details.delta.dx;
  //     });
  //   }
  // }

  void onHorizontalDragUpdate(DragUpdateDetails details, double screenWidth) {
    if (!_enableGesture) return;

    double delta = details.delta.dx;

    // 只允许向左滑动（负方向）
    if (delta < 0) {
      setState(() {
        offsetX += delta;
        // clamp 到 [-screenWidth, 0]
        offsetX = offsetX.clamp(-screenWidth, 0);
      });
    }
    // 可选：如果希望允许右滑回中间
    else if (delta > 0 && offsetX < 0) {
      setState(() {
        offsetX += delta;
        offsetX = offsetX.clamp(-screenWidth, 0);
      });
    }
  }

  // 水平方向滑动结束
  onHorizontalDragEnd(details, screenWidth) {
    if (!_enableGesture) return;
    var vOffset = details.velocity.pixelsPerSecond.dx;

    // 速度很快时
    if (vOffset > scrollSpeed && inMiddle == 0) {
      // 去右边页面
      // return animateToPage(TikTokPagePositon.left);
    } else if (vOffset < -scrollSpeed && inMiddle == 0) {
      // 去左边页面
      // return animateToPage(TikTokPagePositon.right);
    } else if (inMiddle > 0 && vOffset < -scrollSpeed) {
      return animateToPage(TikTokPagePositon.middle, 0);
    } else if (inMiddle < 0 && vOffset > scrollSpeed) {
      return animateToPage(TikTokPagePositon.middle, 0);
    }
    // 当滑动停止的时候 根据 offsetX 的偏移量进行动画
    if (offsetX.abs() < screenWidth * 0.5) {
      // 中间页面
      return animateToPage(TikTokPagePositon.middle, 0);
    } else if (offsetX > 0) {
      // 去左边页面
      // return animateToPage(TikTokPagePositon.left);
    } else {
      // 去右边页面
      return animateToPage(TikTokPagePositon.right, 0);
    }
  }

  //
  // /// 滑动到顶部
  // ///
  // /// [offsetY] to 0.0
  // Future animateToTop() {
  //   animationControllerY = AnimationController(
  //     duration: Duration(milliseconds: offsetY.abs() * 1000 ~/ 60),
  //     vsync: this,
  //   );
  //   final curve = CurvedAnimation(
  //     parent: animationControllerY!,
  //     curve: Curves.easeOutCubic,
  //   );
  //   animationY = Tween(begin: offsetY, end: 0.0).animate(curve)
  //     ..addListener(() {
  //       setState(() {
  //         offsetY = animationY.value;
  //       });
  //     });
  //   return animationControllerY!.forward();
  // }

  CurvedAnimation curvedAnimation() {
    animationControllerX = AnimationController(
      duration: Duration(milliseconds: max(offsetX.abs(), 60) * 1000 ~/ 500),
      vsync: this,
    );
    return CurvedAnimation(
      parent: animationControllerX!,
      curve: Curves.easeOutCubic,
    );
  }

  Future animateTo([double end = 0.0]) {
    final curve = curvedAnimation();

    animationX = Tween(begin: offsetX, end: end).animate(curve)
      ..addListener(() {
        setState(() {
          offsetX = animationX.value;
        });
      });
    inMiddle = end;
    return animationControllerX!.animateTo(1);
  }

  bool absorbing = false;
  double endOffset = 0.0;

  /// 计算[offsetY]
  ///
  /// 手指上滑,[absorbing]为false，不阻止事件，事件交给底层PageView处理
  /// 处于第一页且是下拉，则拦截滑动���件
  void calculateOffsetY(DragUpdateDetails details) {
    if (!_enableGesture) return;
    if (inMiddle != 0) {
      setState(() => absorbing = false);
      return;
    }
    final tempY = offsetY + details.delta.dy / 2;
    if (widget.currentIndex == 0) {
      if (tempY > 0) {
        if (tempY < 40) {
          offsetY = tempY;
        } else if (offsetY != 40) {
          offsetY = 40;
          // vibrate();
        }
      } else {
        absorbing = false;
      }
      setState(() {});
    } else {
      absorbing = false;
      offsetY = 0;
      setState(() {});
    }
  }

  @override
  void dispose() {
    animationControllerX?.dispose();
    animationControllerY?.dispose();
    super.dispose();
  }
}

class _MiddlePage extends StatelessWidget {
  final bool? absorbing;
  final bool isStack;
  final Widget? page;

  final double? offsetX;
  final double? offsetY;
  final Function? onTopDrag;

  final Widget? header;
  final Widget? tabBar;

  const _MiddlePage({
    this.absorbing,
    this.onTopDrag,
    this.offsetX,
    this.offsetY,
    this.isStack = false,
    this.header,
    required this.tabBar,
    this.page,
  });

  @override
  Widget build(BuildContext context) {
    Widget tabBarContainer =
        tabBar ?? SizedBox(height: 44, child: Placeholder(color: Colors.red));
    Widget mainVideoList = Container(
      color: Colors.black,
      padding: EdgeInsets.only(
        bottom: isStack ? 0 : 44 + MediaQuery.of(context).padding.bottom,
      ),
      child: page,
    );
    // 刷新标志
    // Widget headerContain;
    // if (offsetY! >= 20) {
    //   headerContain = Opacity(
    //     opacity: (offsetY! - 20) / 20,
    //     child: Transform.translate(
    //       offset: Offset(0, offsetY!),
    //       child: SizedBox(
    //         height: 44,
    //         child: Center(
    //           child: const Text(
    //             "下拉刷新内容",
    //             style: TextStyle(color: Colors.white, fontSize: 16),
    //           ),
    //         ),
    //       ),
    //     ),
    //   );
    // } else {
    //   headerContain = Opacity(
    //     opacity: max(0, 1 - offsetY! / 20),
    //     child: Transform.translate(
    //       offset: Offset(0, offsetY!),
    //       child: SafeArea(
    //         child: SizedBox(height: 44, child: header ?? SizedBox()),
    //       ),
    //     ),
    //   );
    // }

    Widget middle = Transform.translate(
      offset: Offset(offsetX! > 0 ? offsetX! : offsetX! / 5, 0),
      child: Scaffold(
        extendBody: true,
        bottomNavigationBar: tabBarContainer,
        body: Stack(children: <Widget>[mainVideoList]),
      ),
    );
    if (page is! PageView) {
      return middle;
    }
    return middle;
  }
}

// /// 左侧Widget
// ///
// /// 通过 [Transform.scale] 进行根据 [offsetX] 缩放
// /// 最小 0.88 最大为 1
// class _LeftPageTransform extends StatelessWidget {
//   final double? offsetX;
//   final Widget? content;
//
//   const _LeftPageTransform({Key? key, this.offsetX, this.content})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Transform.scale(
//       scale: 0.88 + 0.12 * offsetX! / screenWidth < 0.88
//           ? 0.88
//           : 0.88 + 0.12 * offsetX! / screenWidth,
//       child: content ?? Placeholder(color: Colors.pink),
//     );
//   }
// }

class _RightPageTransform extends StatelessWidget {
  final double? offsetX;
  final double? offsetY;

  final Widget? content;

  const _RightPageTransform({this.offsetX, this.offsetY, this.content});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Transform.translate(
      offset: Offset(max(0, offsetX! + screenWidth), 0),
      child: Container(
        width: screenWidth,
        height: screenHeight,
        color: Colors.transparent,
        child: content ?? Placeholder(fallbackWidth: screenWidth),
      ),
    );
  }
}
