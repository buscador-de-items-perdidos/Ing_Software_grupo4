import 'dart:ui';

enum TagColor {
  blanco('Blanco', Color.fromARGB(255,255,255,255)),
  negro('Negro', Color.fromARGB(255,0,0,0)),
  rojo('Rojo', Color.fromARGB(255,255,0,0)),
  verde('Verde', Color.fromARGB(255,0,255,0)),
  azul('Azul', Color.fromARGB(255,0,0,255)),
  amarillo('Amarillo', Color.fromARGB(255,255,255,0)),
  naranja('Naranja', Color.fromARGB(255,255,165,0)), 
  morado('Morado', Color.fromARGB(255,128,0,128)), 
  rosa('Rosa', Color.fromARGB(255,255,192,203)), 
  celeste('Celeste', Color.fromARGB(255,135,206,235)), 
  cafe('Café', Color.fromARGB(255,139,69,19)), 
  gris('Gris', Color.fromARGB(255,128,128,128)), 
  turquesa('Turquesa', Color.fromARGB(255,64,224,208)), 
  lima('Lima', Color.fromARGB(255,0,255,127)), 
  cian('Cian', Color.fromARGB(255,0,255,255)), 
  fucsia('Fucsia', Color.fromARGB(255,255,0,255)), 
  beige('Beige', Color.fromARGB(255,245,245,220)), 
  chocolate('Chocolate', Color.fromARGB(255,210,105,30)), 
  dorado('Dorado', Color.fromARGB(255,255,215,0)), 
  plateado('Plateado', Color.fromARGB(255,192,192,192)), 
  azulMarino('Azul Marino', Color.fromARGB(255,0,0,128)), 
  burdeos('Burdeos', Color.fromARGB(255,128,0,32)), 
  otro('Otro', Color.fromARGB(255,255,255,255));
  
  final String name;
  final Color color;

  const TagColor(this.name, this.color);
}
