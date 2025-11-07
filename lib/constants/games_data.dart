import '../models/game_model.dart';

class GamesData {
  // List of all games from FGTP Labs (excluding current game "Sliding Number")
  static List<GameModel> getOtherGames() {
    return [
      GameModel(
        name: "Color Slide",
        image: "https://imagedelivery.net/UMXSRNF_gg8TbPBlMeixSQ/ba0f3eae-30cd-41c8-e3e5-c1519e939200/public?quality=90",
        playstoreUrl: "https://play.google.com/store/apps/details?id=com.fgtp.color_slide",
        appstoreUrl: "https://apps.apple.com/us/app/color-slide-ball-slide-puzzle/id6754687571",
      ),
      GameModel(
        name: "Nummix",
        image: "https://imagedelivery.net/UMXSRNF_gg8TbPBlMeixSQ/1778291c-a853-4999-d707-0bd46cc31c00/public?quality=90",
        playstoreUrl: "https://play.google.com/store/apps/details?id=com.fgtp.nummix",
        appstoreUrl: "https://apps.apple.com/us/app/nummix-puzzle/id6754763674",
      ),
      GameModel(
        name: "Tic-Tac-Toe",
        image: "https://imagedelivery.net/UMXSRNF_gg8TbPBlMeixSQ/4efdfe8a-8b95-4afc-ed3a-d293d1b37800/public?quality=90",
        playstoreUrl: "https://play.google.com/store/apps/details?id=com.fgtp.tic_tac_toe",
        appstoreUrl: "https://apps.apple.com/us/app/tic-tac-toe-modern-grid/id6754626082",
      ),
      GameModel(
        name: "Wimbo",
        image: "https://imagedelivery.net/UMXSRNF_gg8TbPBlMeixSQ/d8f44ca7-28f8-44ef-73a1-3311bbead200/public?quality=90",
        playstoreUrl: "https://play.google.com/store/apps/details?id=com.fgtp.wimbo",
        appstoreUrl: "https://apps.apple.com/us/app/wimbo/id6754673880",
      ),
      GameModel(
        name: "Color Flood",
        image: "https://imagedelivery.net/UMXSRNF_gg8TbPBlMeixSQ/4984b882-f1ea-4dda-dd08-bc5ab7446e00/public?quality=90",
        playstoreUrl: "https://play.google.com/store/apps/details?id=com.fgtp.color_flood",
        appstoreUrl: "https://apps.apple.com/us/app/color-flood-splash-puzzle/id6754686796",
      ),
      GameModel(
        name: "Color Sudoku",
        image: "https://imagedelivery.net/UMXSRNF_gg8TbPBlMeixSQ/042b75ef-14d7-42e0-2f82-303800614c00/public?quality=90",
        playstoreUrl: "https://play.google.com/store/apps/details?id=com.fgtp.color_sudoku",
        appstoreUrl: "https://apps.apple.com/us/app/color-sudoku-color-puzzle/id6754686196",
      ),
      GameModel(
        name: "Trappex",
        image: "https://imagedelivery.net/UMXSRNF_gg8TbPBlMeixSQ/bc207684-a072-46c5-801c-64a06c719900/public?quality=90",
        playstoreUrl: "https://play.google.com/store/apps/details?id=com.fgtp.trappex",
        appstoreUrl: "https://apps.apple.com/us/app/trappex/id6754655051",
      ),
    ];
  }
}

