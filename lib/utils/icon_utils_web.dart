// ignore: deprecated_member_use
import 'dart:js' as js;

void setAppIconFromUrl(String? imageUrl) {
  js.context.callMethod('changeFavicon', [
    imageUrl ??
        "https://image2url.com/images/1765782014808-ad4c21c4-c0a3-4787-a0f5-a2d1b51b7e08.jpg",
  ]);
}
