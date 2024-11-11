class BrokerConfigs {
  // 10.0.2.2
  final String _hostAddress = '192.168.1.2';
  final int _port = 1883;

  String get hostAddress => _hostAddress;
  int get port => _port;
}

class SMMICTopics {
  final String _root = 'smmic';
  final String _adminSettings = '/admin/settings/+';
  final String _adminCommands = '/admin/commands/+';

  // sink
  final String _sinkData = '/sink/data';
  final String _sinkAlert = '/sink/alert';

  // sensors
  final String _sensorData = '/sensor/data';
  final String _sensorAlert = '/sensor/alert';

  // hardware
  final String _irrigation = '/irrigation';

  String get adminSettings => '$_root$_adminSettings';
  String get adminCommands => '$_root$_adminCommands';
  String get sinkData => '$_root$_sinkData';
  String get sinkAlert => '$_root$_sinkAlert';
  String get sensorData => '$_root$_sensorData';
  String get sensorAlert => '$_root$_sensorAlert';
  String get irrigation => '$_root$_irrigation';

  // all topics as list
  List<String> get topics => [
    '$_root$_adminSettings',
    '$_root$_adminCommands',
    '$_root$_sinkData',
    '$_root$_sinkAlert',
    '$_root$_sensorData',
    '$_root$_sensorAlert',
    '$_root$_irrigation'
  ];
}

class MqttConstants {
  final BrokerConfigs broker = BrokerConfigs();
  final SMMICTopics topics = SMMICTopics();
}