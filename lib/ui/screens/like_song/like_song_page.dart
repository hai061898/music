import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:music/bloc/main_controller.dart';
import 'package:music/data/models/song_model.dart';
import 'package:music/ui/methods/snackbar.dart';
import 'package:music/ui/widgets/bottom_sheet_c.dart';
import 'package:music/ui/widgets/loading_image.dart';

class LikedSongs extends StatelessWidget {
  final MainController con;
  const LikedSongs({
    Key? key,
    required this.con,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<dynamic> data = [];
    return Scaffold(
        body: CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 200,
          backgroundColor: Colors.black,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            collapseMode: CollapseMode.pin,
            background: ClipRRect(
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl:
                        'https://img.freepik.com/free-vector/dark-gradient-background-with-copy-space_53876-99548.jpg?size=626&ext=jpg&ga=GA1.1.2112483155.1644105600',
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.black,
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                      height: 250,
                      width: MediaQuery.of(context).size.width,
                    ),
                  )
                ],
              ),
            ),
            title: Text(
              "Liked Songs",
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ValueListenableBuilder<Box>(
              valueListenable: Hive.box('liked').listenable(),
              builder: (context, box, child) {
                if (box.isEmpty) {
                  return const SizedBox(
                    height: 300,
                    child: Center(
                      child: Text(
                        "You don't have any liked songs",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i) {
                    final info = Hive.box('liked').getAt(i);
                    data.add(info);

                    return Dismissible(
                      key: Key(info['songname'].toString()),
                      onDismissed: (direction) {
                        box.deleteAt(i);
                        context.showSnackBar(
                            message: "Removed from liked songs.");
                      },
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        child: const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Icon(
                            CupertinoIcons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      child: ListTile(
                        onTap: () {
                          con.playSong(con.converLocalSongToAudio(data), i);
                        },
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: CachedNetworkImage(
                              imageUrl: info['cover'],
                              width: 50,
                              height: 50,
                              placeholder: (context, u) => const LoadingImage(),
                              fit: BoxFit.cover),
                        ),
                        title: Text(
                          info['songname'],
                          maxLines: 1,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          info['fullname'],
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                                useRootNavigator: true,
                                isScrollControlled: true,
                                elevation: 100,
                                backgroundColor: Colors.black38,
                                context: context,
                                builder: (context) {
                                  return BottomSheetWidget(
                                      con: con,
                                      song: SongModel(
                                        songid: info['id'],
                                        songname: info['songname'],
                                        userid: info['username'],
                                        trackid: info['track'],
                                        duration: '',
                                        coverImageUrl: info['cover'],
                                        name: info['fullname'],
                                      ));
                                });
                          },
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: box.length,
                );
              }),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 150),
        )
      ],
    ));
  }
}