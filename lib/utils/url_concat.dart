String buildClaimUrl({
  required String claimUrl,
  required Map<String, dynamic> extraParams,
  required String apiBase,
}) {
  final query = _encodeParams(extraParams);
  if (claimUrl.startsWith("http")) {
    return "$claimUrl$query";
  }
  return "$apiBase$claimUrl$query";
}

String buildJumpUrl({
  required String jumpUrl,
  required Map<String, dynamic> extraParams,
}) {
  final query = _encodeParams(extraParams);
  if (jumpUrl.startsWith("http")) {
    return "$jumpUrl$query";
  }
  return "$jumpUrl$query";
}

String _encodeParams(Map<String, dynamic> params) {
  if (params.isEmpty) return "";
  final encoded = params.entries
      .map((e) {
        final key = Uri.encodeComponent(e.key);
        final value = Uri.encodeComponent(e.value.toString());
        return "$key=$value";
      })
      .join("&");
  return "?$encoded";
}
