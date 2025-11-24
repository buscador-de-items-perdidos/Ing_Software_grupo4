import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ing_software_grupo4/cambio_contactos.dart';
import 'package:ing_software_grupo4/cambio_contactos_movil.dart';
import 'package:ing_software_grupo4/modelos/modo.dart';
import 'package:ing_software_grupo4/modelos/reporte.dart';
import 'package:ing_software_grupo4/report_display.dart';
import 'package:ing_software_grupo4/report_display_movil.dart';

///Esta funcion entrega un report_display distinto dependiendo de la plataforma.
Widget mostrarReporte(Reporte reporte, String nombre, {required Modo modo}) {
  if (modo != Modo.Editar) {
    return ReportDisplayMovil(reporte, nombre, modo);
  } else
    return ReportDisplay(reporte, nombre, modo: modo);
}

Widget mostrarDatosContacto(){
  if(Platform.isIOS || Platform.isAndroid){
    return CambioContactosMovil();
  } else {
    return CambioContactos();
  }
}
