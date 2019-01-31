class RecordEntity {
  RecordEntity(
      {this.id, this.comment, this.startDateTime, this.endDateTime, this.image,this.isBlank,this.hasSelectTime});

  int id = 0;
  String comment='';
  bool hasSelectTime = false;
  int startDateTime = -1;
  int endDateTime = -1;
  String image;
  bool isBlank = false;
}
