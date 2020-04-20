import 'package:flutter/material.dart';
import 'package:wowsinfo/core/data/CachedData.dart';
import 'package:wowsinfo/core/models/User/Player.dart';
import 'package:wowsinfo/core/models/WoWs/BasicPlayerInfo.dart';
import 'package:wowsinfo/core/models/WoWs/PlayerAchievement.dart';
import 'package:wowsinfo/core/models/WoWs/PlayerClanTag.dart';
import 'package:wowsinfo/core/models/WoWs/PlayerShipInfo.dart';
import 'package:wowsinfo/core/models/WoWs/PvP.dart';
import 'package:wowsinfo/core/models/WoWs/RankPlayerInfo.dart';
import 'package:wowsinfo/core/models/WoWs/RankPlayerShipInfo.dart';
import 'package:wowsinfo/core/others/Utils.dart';
import 'package:wowsinfo/core/parsers/API/BasicPlayerInfoParser.dart';
import 'package:wowsinfo/core/parsers/API/PlayerAchievementParser.dart';
import 'package:wowsinfo/core/parsers/API/PlayerClanTagParser.dart';
import 'package:wowsinfo/core/parsers/API/PlayerShipInfoParser.dart';
import 'package:wowsinfo/core/parsers/API/RankPlayerInfoParser.dart';
import 'package:wowsinfo/core/parsers/API/RankPlayerShipInfoParser.dart';
import 'package:wowsinfo/ui/pages/player/ClanInfoPage.dart';
import 'package:wowsinfo/ui/pages/wiki/WikiAchievementPage.dart';
import 'package:wowsinfo/ui/widgets/PlatformLoadingIndiactor.dart';
import 'package:wowsinfo/ui/widgets/TextWithCaption.dart';
import 'package:wowsinfo/ui/widgets/WrapBox.dart';
import 'package:wowsinfo/ui/widgets/player/BasicPlayerTile.dart';
import 'package:wowsinfo/ui/widgets/wiki/WikiWarshipCell.dart';

/// PlayerInfoPage class
class PlayerInfoPage extends StatefulWidget {
  final Player player;
  PlayerInfoPage({Key key, this.player}) : super(key: key);

  @override
  _PlayerInfoPageState createState() => _PlayerInfoPageState();
}

class _PlayerInfoPageState extends State<PlayerInfoPage> {
  final cached = CachedData.shared;
  BasicPlayerInfo basicInfo;
  PlayerAchievement achievement;
  PlayerShipInfo shipInfo;
  RankPlayerInfo rankInfo;
  RankPlayerShipInfo rankShipInfo;
  PlayerClanTag clanTag;

  @override
  void initState() {
    super.initState();
    this.loadAll();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
    else Utils.debugPrint('Cancel set state');
  }

  void loadAll() async {
    final server = widget.player.server;
    final accountId = widget.player.playerId;
    final basic = BasicPlayerInfoParser(server, accountId);
    final basicInfo = basic.parse(await basic.download());
    if (basicInfo != null) {
      setState(() {
        // Update basic info first
        this.basicInfo = basicInfo;
      });

      // Check if this is a public profile
      if (basicInfo.publicProfile) {
        // Request for clan tag
        final tag = PlayerClanTagParser(server, accountId);
        final clanTag = tag.parse(await tag.download());
        if (clanTag != null) {
          setState(() {
            this.clanTag = clanTag;
          });
        }

        // Request for achievement
        final a = PlayerAchievementParser(server, accountId);
        final achievement = a.parse(await a.download());
        if (achievement != null) {
          setState(() {
            this.achievement = achievement;
          });
        }

        // Request for ship
        final ship = PlayerShipInfoParser(server, accountId);
        final shipInfo = ship.parse(await ship.download());
        if (shipInfo != null) {
          setState(() {
            this.shipInfo = shipInfo;
          });
        }

        // Request for rank
        final r = RankPlayerInfoParser(server, accountId);
        final rankInfo = r.parse(await r.download());
        if (rankInfo != null) {
          setState(() {
            this.rankInfo = rankInfo;
          });
        }

        // Request for rank ship
        final rs = RankPlayerShipInfoParser(server, accountId);
        final rankShipInfo = rs.parse(await rs.download());
        if (rankShipInfo != null) {
          setState(() {
            this.rankShipInfo = rankShipInfo;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.player.playerIdString)
      ),
      body: SafeArea(
        child: Center(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            transitionBuilder: (w, a) => ScaleTransition(scale: a, child: w),
            switchInCurve: Curves.linearToEaseOut,
            child: buildBasicInfo(context),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            buildAchievement(context),
          ],
        ),
      ),
    );
  }

  Widget buildAchievement(BuildContext context) {
    if (achievement == null) return SizedBox.shrink();
    return FlatButton(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => WikiAchievementPage(player: achievement))), 
      child: Text('Achievement')
    );
  }

  Widget buildBasicInfo(BuildContext context) {
    if (basicInfo == null || clanTag == null) return PlatformLoadingIndiactor();

    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      child: Column(
        children: [
          buildNickname(context, textTheme),
          buildPlayerInfo(),
          buildStatistics(),
        ],
      ),
    );
  }

  WrapBox buildPlayerInfo() {
    return WrapBox(
      width: 100,
      children: [
        TextWithCaption(
          title: 'Level',
          value: basicInfo.level,
        ),
        TextWithCaption(
          title: 'Created',
          value: basicInfo.createdDate,
        ),
        TextWithCaption(
          title: 'Last battle',
          value: basicInfo.lastBattleDate,
        ),
        TextWithCaption(
          title: 'Total battle',
          value: basicInfo.totalBattleString,
        ),
        TextWithCaption(
          title: 'Distance travlled',
          value: basicInfo.distanceString,
        ),
      ],
    );
  }

  Widget buildStatistics() {
    final stats = basicInfo.statistic;
    if (stats == null) return SizedBox.shrink();
    return Column(
      children: [
        ExpansionTile(
          title: Text('Random Battle'),
          initiallyExpanded: true,
          children: [
            BasicPlayerTile(stats: basicInfo.statistic.pvp),
            buildRecord(basicInfo.statistic.pvp),
          ],
        ),
        ExpansionTile(
          title: Text('Random Battle Solo'),
          children: [
            BasicPlayerTile(stats: basicInfo.statistic.solo),
            buildRecord(basicInfo.statistic.solo),
          ],
        ),
        ExpansionTile(
          title: Text('Random Battle Div2'),
          children: [
            BasicPlayerTile(stats: basicInfo.statistic.div2),
            buildRecord(basicInfo.statistic.div2),
          ],
        ),
        ExpansionTile(
          title: Text('Random Battle Div3'),
          children: [
            BasicPlayerTile(stats: basicInfo.statistic.div3),
            buildRecord(basicInfo.statistic.div3),
          ],
        ),
      ],
    );
  }

  /// Merge clan tag and player together
  InkWell buildNickname(BuildContext context, TextTheme textTheme) {
    return InkWell(
      onTap: clanTag.hasTag 
      ? () => Navigator.push(context, MaterialPageRoute(builder: (c) => ClanInfoPage(clan: clanTag.clan)))
      : null,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          clanTag.hasTag 
          ? clanTag.tagString + '\n${basicInfo.nickname}' 
          : basicInfo.nickname, 
          textAlign: TextAlign.center,
          style: textTheme.headline6.copyWith(fontSize: 24)
        ),
      )
    );
  }

  Widget buildRecord(PvP pvp) {
    if (pvp == null) return SizedBox.shrink();
    return WrapBox(
      width: 200,
      height: 150,
      itemPadding: const EdgeInsets.only(top: 8),
      children: [
        RecordValue(pvp.maxDamageDealtShipId, 'damage', pvp.maxDamage),
        RecordValue(pvp.maxXpShipId, 'max exp', pvp.maxExp),
        RecordValue(pvp.maxFragsShipId, 'max frag', pvp.maxFrag),
        RecordValue(pvp.maxTotalAgroShipId, 'max potential', pvp.maxPotential),
        RecordValue(pvp.maxShipsSpottedShipId, 'max spotted', pvp.maxSpotted),
        RecordValue(pvp.maxScoutingDamageShipId, 'max spotting', pvp.maxSpottingDamage),
        RecordValue(pvp.maxPlanesKilledShipId, 'max plane destoryed', pvp.maxPlane),
        RecordValue(pvp.maxDamageDealtToBuildingsShipId, 'damage to buildings', pvp.maxDamageToBuilding),
        RecordValue(pvp.maxSuppressionsShipId, 'max supression', pvp.maxSupression),
      ].where((e) => cached.getShip(e.shipId) != null).map((e) => WikiWarshipCell(
        showDetail: true,
        ship: cached.getShip(e.shipId),
        bottom: TextWithCaption(
          title: e.title,
          value: e.value,
        ),
      )).toList(growable: false),
    );
  }
}

/// Stores all value relating to record (max something)
class RecordValue {
  int shipId;
  String title;
  String value;

  RecordValue(this.shipId, this.title, this.value);
}
