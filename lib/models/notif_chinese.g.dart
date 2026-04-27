// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notif_chinese.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotifLink _$NotifLinkFromJson(Map<String, dynamic> json) =>
    NotifLink(link: json['link'] as String, text: json['text'] as String);

Map<String, dynamic> _$NotifLinkToJson(NotifLink instance) => <String, dynamic>{
  'link': instance.link,
  'text': instance.text,
};

NotifChinese _$NotifChineseFromJson(Map<String, dynamic> json) => NotifChinese(
  body: (json['body'] as List<dynamic>).map((e) => e as String).toList(),
  title: json['title'] as String,
  linkList: (json['linkList'] as List<dynamic>)
      .map((e) => NotifLink.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$NotifChineseToJson(NotifChinese instance) =>
    <String, dynamic>{
      'body': instance.body,
      'title': instance.title,
      'linkList': instance.linkList,
    };
