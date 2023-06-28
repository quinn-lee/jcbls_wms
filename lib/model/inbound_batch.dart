class InboundBatch {
  late int id;
  String? batchNum;
  int? quantity;
  String? spaceNum;
  Map? baseSku;

  InboundBatch(this.id,
      {this.batchNum, this.quantity, this.spaceNum, this.baseSku});

  InboundBatch.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    batchNum = json['batch_num'];
    quantity = json['quantity'];
    spaceNum = json['space_num'];
    baseSku = json['base_sku'];
  }
}
