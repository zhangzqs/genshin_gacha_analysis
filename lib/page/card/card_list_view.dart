import 'package:flutter/material.dart';
import 'package:genshin_wish_analysis/service/gacha_service.dart';
import 'package:intl/intl.dart';

class CardListView extends StatelessWidget {
  final List<GachaRecordEntity> list;

  const CardListView({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return const Center(child: Text('无记录'));
    }
    return ListView(
      children: list.map((e) {
        return ListTile(
          title: Text(e.name),
          subtitle: Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(e.time)),
          leading: Icon(
            e.type == GachaResultItemType.character
                ? Icons.person
                : Icons.device_unknown,
          ),
          trailing: (int rank) {
            switch (rank) {
              case 4:
                return Text('$rank星',
                    style: const TextStyle(color: Colors.purple));
              case 5:
                return Text('$rank星',
                    style: const TextStyle(color: Colors.yellow));
              default:
                return Text('$rank星');
            }
          }(e.rank),
        );
      }).toList(),
    );
  }
}
