import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum CitaEstado {
  citaCreada('CITA_CREADA'),
  correoConfirmado('CORREO_CONFIRMADO'),
  enEsperaFirma('EN_ESPERA_FIRMA'),
  firmado('FIRMADO'),
  documentoSubido('DOCUMENTO_SUBIDO'),
  pendienteEnvioContrato('PENDIENTE_ENVIO_CONTRATO'),
  contratoEnviado('CONTRATO_ENVIADO'),
  cerrada('CERRADA'),
  noSePresento('NO_SE_PRESENTO'),
  reagendada('REAGENDADA'),
  cancelada('CANCELADA'),
  vencida('VENCIDA');

  final String dbValue;
  const CitaEstado(this.dbValue);

  static CitaEstado fromDb(String value) =>
      CitaEstado.values.firstWhere((e) => e.dbValue == value,
          orElse: () => CitaEstado.citaCreada);

  String get label {
    switch (this) {
      case CitaEstado.citaCreada:
        return 'Cita creada';
      case CitaEstado.correoConfirmado:
        return 'Correo confirmado';
      case CitaEstado.enEsperaFirma:
        return 'En espera de firma';
      case CitaEstado.firmado:
        return 'Firmado';
      case CitaEstado.documentoSubido:
        return 'Documento subido';
      case CitaEstado.pendienteEnvioContrato:
        return 'Pendiente envío de contrato';
      case CitaEstado.contratoEnviado:
        return 'Contrato enviado';
      case CitaEstado.cerrada:
        return 'Cerrada';
      case CitaEstado.noSePresento:
        return 'No se presentó';
      case CitaEstado.reagendada:
        return 'Reagendada';
      case CitaEstado.cancelada:
        return 'Cancelada';
      case CitaEstado.vencida:
        return 'Vencida';
    }
  }

  Color get color {
    switch (this) {
      case CitaEstado.citaCreada:
        return Colors.grey.shade400;
      case CitaEstado.correoConfirmado:
      case CitaEstado.enEsperaFirma:
        return AppColors.info;
      case CitaEstado.firmado:
      case CitaEstado.documentoSubido:
        return AppColors.success;
      case CitaEstado.pendienteEnvioContrato:
        return AppColors.pendiente;
      case CitaEstado.contratoEnviado:
      case CitaEstado.cerrada:
        return AppColors.enviada;
      case CitaEstado.noSePresento:
        return AppColors.warning;
      case CitaEstado.reagendada:
        return const Color(0xFFB8860B);
      case CitaEstado.cancelada:
        return AppColors.danger;
      case CitaEstado.vencida:
        return AppColors.vencida;
    }
  }

  /// Transiciones válidas desde este estado.
  List<CitaEstado> get nextStates {
    switch (this) {
      case CitaEstado.citaCreada:
        return [CitaEstado.correoConfirmado, CitaEstado.cancelada];
      case CitaEstado.correoConfirmado:
        return [
          CitaEstado.enEsperaFirma,
          CitaEstado.noSePresento,
          CitaEstado.cancelada,
        ];
      case CitaEstado.enEsperaFirma:
        return [
          CitaEstado.firmado,
          CitaEstado.noSePresento,
          CitaEstado.cancelada,
        ];
      case CitaEstado.firmado:
        return [CitaEstado.documentoSubido, CitaEstado.cancelada];
      case CitaEstado.documentoSubido:
        return [CitaEstado.pendienteEnvioContrato, CitaEstado.cancelada];
      case CitaEstado.pendienteEnvioContrato:
        return [
          CitaEstado.contratoEnviado,
          CitaEstado.vencida,
          CitaEstado.cancelada,
        ];
      case CitaEstado.contratoEnviado:
        return [CitaEstado.cerrada];
      case CitaEstado.noSePresento:
        return [CitaEstado.reagendada, CitaEstado.cancelada];
      case CitaEstado.reagendada:
        return [CitaEstado.enEsperaFirma, CitaEstado.cancelada];
      case CitaEstado.cerrada:
      case CitaEstado.cancelada:
      case CitaEstado.vencida:
        return const [];
    }
  }

  bool get esFinal =>
      this == CitaEstado.cerrada ||
      this == CitaEstado.cancelada ||
      this == CitaEstado.vencida;
}
