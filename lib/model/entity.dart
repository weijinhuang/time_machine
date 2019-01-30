class RecordEntity {
  RecordEntity(
      {this.id, this.comment, this.startTime, this.endTime, this.image,this.isBlank,this.hasSelectTime});

  double id;
  String comment;
  bool hasSelectTime;
  int startTime;
  int endTime;
  String image;
  bool isBlank;
}
