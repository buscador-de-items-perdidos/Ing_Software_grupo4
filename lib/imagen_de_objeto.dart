part of 'report_display.dart';
class _ImagenDeObjeto extends StatelessWidget {
  const _ImagenDeObjeto();

  @override
  Widget build(BuildContext context) {
    if (true) {
      //Esta condición a futuro seria si el reporte tiene una imagen, por ahora asumimos que sí
      return Expanded(
        child: CircleAvatar(
          backgroundImage: AssetImage('assets/trial.jpeg'),
          maxRadius: 99999,
        ),
      );
    }
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(70.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: BoxBorder.all(color: Colors.deepPurpleAccent, width: 1),
          ),
          child: SizedBox.expand(),
        ),
      ),
    );
  }
}

