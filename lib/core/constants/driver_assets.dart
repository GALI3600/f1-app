/// Driver assets for visual data not available from Jolpica API
/// Contains: headshot URLs, team names, team colors
class DriverAssets {
  DriverAssets._();

  /// Driver data by driver ID (from Jolpica API)
  /// Format: driverId -> {teamName, teamColour, headshotUrl}
  static const Map<String, Map<String, String>> drivers = {
    // 2026 Grid - Red Bull
    'max_verstappen': {
      'teamName': 'Red Bull Racing',
      'teamColour': '3671C6',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/M/MAXVER01_Max_Verstappen/maxver01.png.transform/1col/image.png',
    },
    'hadjar': {
      'teamName': 'Red Bull Racing',
      'teamColour': '3671C6',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/I/ISAHAD01_Isack_Hadjar/isahad01.png.transform/1col/image.png',
    },
    // Ferrari
    'leclerc': {
      'teamName': 'Ferrari',
      'teamColour': 'E8002D',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/C/CHALEC01_Charles_Leclerc/chalec01.png.transform/1col/image.png',
    },
    'hamilton': {
      'teamName': 'Ferrari',
      'teamColour': 'E8002D',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/L/LEWHAM01_Lewis_Hamilton/lewham01.png.transform/1col/image.png',
    },
    // Mercedes
    'russell': {
      'teamName': 'Mercedes',
      'teamColour': '27F4D2',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/G/GEORUS01_George_Russell/georus01.png.transform/1col/image.png',
    },
    'antonelli': {
      'teamName': 'Mercedes',
      'teamColour': '27F4D2',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/A/ANDANT01_Andrea%20Kimi_Antonelli/andant01.png.transform/1col/image.png',
    },
    // McLaren
    'norris': {
      'teamName': 'McLaren',
      'teamColour': 'FF8000',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/L/LANNOR01_Lando_Norris/lannor01.png.transform/1col/image.png',
    },
    'piastri': {
      'teamName': 'McLaren',
      'teamColour': 'FF8000',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/O/OSCPIA01_Oscar_Piastri/oscpia01.png.transform/1col/image.png',
    },
    // Aston Martin
    'alonso': {
      'teamName': 'Aston Martin',
      'teamColour': '229971',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/F/FERALO01_Fernando_Alonso/feralo01.png.transform/1col/image.png',
    },
    'stroll': {
      'teamName': 'Aston Martin',
      'teamColour': '229971',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/L/LANSTR01_Lance_Stroll/lanstr01.png.transform/1col/image.png',
    },
    // Alpine
    'gasly': {
      'teamName': 'Alpine',
      'teamColour': 'FF87BC',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/P/PIEGAS01_Pierre_Gasly/piegas01.png.transform/1col/image.png',
    },
    'colapinto': {
      'teamName': 'Alpine',
      'teamColour': 'FF87BC',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/F/FRACOL01_Franco_Colapinto/fracol01.png.transform/1col/image.png',
    },
    // Williams
    'albon': {
      'teamName': 'Williams',
      'teamColour': '64C4FF',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/A/ALEALB01_Alexander_Albon/alealb01.png.transform/1col/image.png',
    },
    'sainz': {
      'teamName': 'Williams',
      'teamColour': '64C4FF',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/C/CARSAI01_Carlos_Sainz/carsai01.png.transform/1col/image.png',
    },
    // RB (Racing Bulls)
    'lawson': {
      'teamName': 'RB',
      'teamColour': '6692FF',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/L/LIALAW01_Liam_Lawson/lialaw01.png.transform/1col/image.png',
    },
    'lindblad': {
      'teamName': 'RB',
      'teamColour': '6692FF',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/A/ARVLIN01_Arvid_Lindblad/arvlin01.png.transform/1col/image.png',
    },
    // Audi (formerly Sauber) - gray to red gradient
    'hulkenberg': {
      'teamName': 'Audi',
      'teamColour': '6E6E6E',
      'teamColour2': 'E30613',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/N/NICHUL01_Nico_Hulkenberg/nichul01.png.transform/1col/image.png',
    },
    'bortoleto': {
      'teamName': 'Audi',
      'teamColour': '6E6E6E',
      'teamColour2': 'E30613',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/G/GABBOR01_Gabriel_Bortoleto/gabbor01.png.transform/1col/image.png',
    },
    // Haas
    'ocon': {
      'teamName': 'Haas F1 Team',
      'teamColour': 'B6BABD',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/E/ESTOCO01_Esteban_Ocon/estoco01.png.transform/1col/image.png',
    },
    'bearman': {
      'teamName': 'Haas F1 Team',
      'teamColour': 'B6BABD',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/O/OLIBEA01_Oliver_Bearman/olibea01.png.transform/1col/image.png',
    },
    // Cadillac
    'bottas': {
      'teamName': 'Cadillac',
      'teamColour': 'D4AF37',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/V/VALBOT01_Valtteri_Bottas/valbot01.png.transform/1col/image.png',
    },
    'perez': {
      'teamName': 'Cadillac',
      'teamColour': 'D4AF37',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/S/SERPER01_Sergio_Perez/serper01.png.transform/1col/image.png',
    },
    // Historical/Reserve drivers
    'tsunoda': {
      'teamName': 'RB',
      'teamColour': '6692FF',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/Y/YUKTSU01_Yuki_Tsunoda/yuktsu01.png.transform/1col/image.png',
    },
    'vettel': {
      'teamName': 'Aston Martin',
      'teamColour': '229971',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/S/SEBVET01_Sebastian_Vettel/sebvet01.png.transform/1col/image.png',
    },
    'ricciardo': {
      'teamName': 'RB',
      'teamColour': '6692FF',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/D/DANRIC01_Daniel_Ricciardo/danric01.png.transform/1col/image.png',
    },
    'magnussen': {
      'teamName': 'Haas F1 Team',
      'teamColour': 'B6BABD',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/K/KEVMAG01_Kevin_Magnussen/kevmag01.png.transform/1col/image.png',
    },
    'zhou': {
      'teamName': 'Sauber',
      'teamColour': '52E252',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/G/GUAZHO01_Guanyu_Zhou/guazho01.png.transform/1col/image.png',
    },
    'sargeant': {
      'teamName': 'Williams',
      'teamColour': '64C4FF',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/L/LOGSAR01_Logan_Sargeant/logsar01.png.transform/1col/image.png',
    },
    'de_vries': {
      'teamName': 'AlphaTauri',
      'teamColour': '2B4562',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/N/NYCDEV01_Nyck_De_Vries/nycdev01.png.transform/1col/image.png',
    },
    'latifi': {
      'teamName': 'Williams',
      'teamColour': '64C4FF',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/N/NICLAF01_Nicholas_Latifi/niclaf01.png.transform/1col/image.png',
    },
    'schumacher': {
      'teamName': 'Haas F1 Team',
      'teamColour': 'B6BABD',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/M/MICSCH02_Mick_Schumacher/micsch02.png.transform/1col/image.png',
    },
    'raikkonen': {
      'teamName': 'Alfa Romeo',
      'teamColour': '900000',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/K/KIMRAI01_Kimi_Raikkonen/kimrai01.png.transform/1col/image.png',
    },
    'giovinazzi': {
      'teamName': 'Alfa Romeo',
      'teamColour': '900000',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/A/ANTGIO01_Antonio_Giovinazzi/antgio01.png.transform/1col/image.png',
    },
    'kubica': {
      'teamName': 'Alfa Romeo',
      'teamColour': '900000',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/R/ROBKUB01_Robert_Kubica/robkub01.png.transform/1col/image.png',
    },
    'grosjean': {
      'teamName': 'Haas F1 Team',
      'teamColour': 'B6BABD',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/R/ROMGRO01_Romain_Grosjean/romgro01.png.transform/1col/image.png',
    },
    'kvyat': {
      'teamName': 'AlphaTauri',
      'teamColour': '2B4562',
      'headshotUrl': 'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/D/DANQUA01_Daniil_Kvyat/danqua01.png.transform/1col/image.png',
    },
  };

  /// Get driver data by driver ID
  static Map<String, String>? getDriver(String driverId) {
    return drivers[driverId];
  }

  /// Get team name by driver ID
  static String getTeamName(String driverId) {
    return drivers[driverId]?['teamName'] ?? 'Unknown';
  }

  /// Get team color by driver ID
  static String getTeamColour(String driverId) {
    return drivers[driverId]?['teamColour'] ?? '2D2D2D';
  }

  /// Get secondary team color by driver ID (for gradients)
  /// Returns null if team doesn't have a gradient
  static String? getTeamColour2(String driverId) {
    return drivers[driverId]?['teamColour2'];
  }

  /// Check if team has gradient colors
  static bool hasGradient(String driverId) {
    return drivers[driverId]?['teamColour2'] != null;
  }

  /// Get headshot URL by driver ID
  static String? getHeadshotUrl(String driverId) {
    return drivers[driverId]?['headshotUrl'];
  }

  /// Default fallback headshot URL
  static const String fallbackHeadshotUrl =
      'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/default.png.transform/1col/image.png';
}
