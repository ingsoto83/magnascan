
class Record {
  int id;
  String codigo;
  String codigo_original;
  int quantity;
  String date;
  String time;
  String user;


  Record({this.id,this.codigo, this.codigo_original, this.quantity,  this.date, this.time, this.user});

  factory Record.fromMap(Map<String, dynamic> json) => new Record(
    id: json["id"],
    codigo: json["codigo"],
    codigo_original: json["codigo_original"],
    quantity: json["quantity"],
    date: json["date"],
    time: json["time"],
    user: json["user"]
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "codigo": codigo,
    "codigo_original": codigo_original,
    "quantity": quantity,
    "date": date,
    "time": time,
    "user": user
  };
}