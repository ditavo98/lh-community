import 'dart:convert';

class CMReason {
  int? id;
  String? type;
  String? reason;

  CMReason({
    this.id,
    this.type,
    this.reason,
  });

  factory CMReason.fromJson(Map<String, dynamic> json) => CMReason(
        id: json["id"],
        type: json["type"],
        reason: json["reason"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "reason": reason,
      };
}

ReportModel reportModelFromJson(String str) =>
    ReportModel.fromJson(json.decode(str));

String reportModelToJson(ReportModel data) => json.encode(data.toJson());

class ReportModel {
  String? id;
  String? target;
  String? targetId;
  String? type;
  String? reason;
  int? isHidden;
  String? progressStep;
  DateTime? reportedAt;

  ReportModel({
    this.id,
    this.target,
    this.targetId,
    this.type,
    this.reason,
    this.isHidden,
    this.progressStep,
    this.reportedAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) => ReportModel(
        id: json["id"],
        target: json["target"],
        targetId: json["target_id"],
        type: json["type"],
        reason: json["reason"],
        isHidden: json["is_hidden"],
        progressStep: json["progress_step"],
        reportedAt: json["reported_at"] == null
            ? null
            : DateTime.parse(json["reported_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "target": target,
        "target_id": targetId,
        "type": type,
        "reason": reason,
        "is_hidden": isHidden,
        "progress_step": progressStep,
        "reported_at": reportedAt?.toIso8601String(),
      };
}

ReportRequestModel reportRequestModelFromJson(String str) =>
    ReportRequestModel.fromJson(json.decode(str));

String reportRequestModelToJson(ReportRequestModel data) =>
    json.encode(data.toJson());

class ReportRequestModel {
  String? target;
  int? targetId;
  List<CMReason>? reasons;
  String? type;

  ReportRequestModel({
    this.target,
    this.targetId,
    this.reasons,
    this.type,
  });

  factory ReportRequestModel.fromJson(Map<String, dynamic> json) =>
      ReportRequestModel(
        target: json["target"],
        targetId: json["targetId"],
        type: json["type"],
        reasons: json["reasons"] == null
            ? []
            : List<CMReason>.from(
                json["reasons"]!.map((x) => CMReason.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "target": target,
        "targetId": targetId,
        "type": type,
        "reasons": reasons == null
            ? []
            : List<dynamic>.from(reasons!.map((x) => x.toJson())),
      };
}
