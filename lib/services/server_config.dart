class ServerConfig {
  static const String serverIp = '192.168.130.242';
  static const int port = 8080;
  static const String baseUrl = 'http://$serverIp:$port';
  static const String uploadEndpoint = '/api/upload-pdf';
  static const String networkPath =
      '\\\\192.168.130.242\\Relatorios\\RPT\\Felipe savio\\checklist-conferente';

  // Caminho Linux/Windows para o servidor salvar
  static const String serverSavePath =
      '/mnt/Relatorios/RPT/Felipe savio/checklist-conferente';
  // Ou para Windows:
  // static const String serverSavePath = 'D:\\Relatorios\\RPT\\Felipe savio\\checklist-conferente';
}
