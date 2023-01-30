import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:genshin_wish_analysis/global.dart';
import 'package:genshin_wish_analysis/page/card/card_list_view.dart';
import 'package:genshin_wish_analysis/service/gacha_service.dart';
import 'package:genshin_wish_analysis/service/gacha_type_enum.dart';
import 'package:intl/intl.dart';

class GachaHistoryView extends StatefulWidget {
  const GachaHistoryView({super.key});

  @override
  State<GachaHistoryView> createState() => _GachaHistoryViewState();
}

class _GachaHistoryViewState extends State<GachaHistoryView> {
  final mhyService = GlobalObjects.mhyService;
  final gachaService = GlobalObjects.gachaService;

  List<GachaRecordEntity>? list;
  int idx = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      switchTo(0);
    });
  }

  void switchTo(int i) async {
    setState(() {
      idx = i;
      list = null;
    });
    final uri = await mhyService.getGachaUrl(
      gachaType: GachaType.values[i],
    );
    final list1 = await gachaService.fetch(uri);
    setState(() {
      list = list1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: idx,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('抽卡记录'),
          bottom: TabBar(
            tabs: const [
              Tab(text: '限时角色卡池'),
              Tab(text: '限时武器卡池'),
              Tab(text: '常驻卡池'),
              Tab(text: '新手卡池'),
            ],
            isScrollable: true,
            onTap: (int v) {
              switchTo(v);
            },
          ),
        ),
        body: list == null
            ? const Center(
                child: Text('正在获取'),
              )
            : CardListView(list: list!),
      ),
    );
  }
}
