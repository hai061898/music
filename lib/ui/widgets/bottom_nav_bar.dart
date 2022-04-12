import 'dart:ui';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:music/bloc/main_controller.dart';
import 'package:music/ui/screens/home/home_page.dart';
import 'package:music/ui/screens/library/library_page.dart';
import 'package:music/ui/screens/play_song/curent_playing.dart';
import 'package:music/ui/screens/search/search_page.dart';
import 'package:music/ui/widgets/custom_cup.dart';
import 'package:music/ui/widgets/loading_image.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AppState();
}

class AppState extends State<App> {
  String _currentPage = "Page1";
  List<String> pageKeys = ["Page1", "Page2", "Page3"];
  final Map<String, GlobalKey<NavigatorState>> _navigatorKeys = {
    "Page1": GlobalKey<NavigatorState>(),
    "Page2": GlobalKey<NavigatorState>(),
    "Page3": GlobalKey<NavigatorState>(),
  };
  int _selectedIndex = 0;

  void _selectTab(String tabItem, int index) {
    if (tabItem == _currentPage) {
      _navigatorKeys[tabItem]!.currentState!.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentPage = pageKeys[index];
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[_currentPage]!.currentState!.maybePop();
        if (isFirstRouteInCurrentTab) {
          if (_currentPage != "Page1") {
            _selectTab("Page1", 1);

            return false;
          }
        }
        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },
      child: ChangeNotifierProvider(
        create: (context) => MainController()..init(),
        child: Consumer<MainController>(
          builder: (context, con, child) {
            return Scaffold(
              extendBody: true,
              resizeToAvoidBottomInset: true,
              body: Stack(children: [
                _buildOffstageNavigator(con, "Page1"),
                _buildOffstageNavigator(con, "Page2"),
                _buildOffstageNavigator(con, "Page3"),
              ]),
              bottomNavigationBar: CustomCupertinoTabBar(
                bottomPlayWidget: PlayWidget(con: con),
                activeColor: Colors.white,
                backgroundColor: Colors.transparent,
                iconSize: 24.0,
                onTap: (int index) {
                  _selectTab(pageKeys[index], index);
                },
                currentIndex: _selectedIndex,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(LineIcons.home),
                    label: 'Home',
                    activeIcon: Icon(LineIcons.home),
                  ),
                  BottomNavigationBarItem(
                    activeIcon: Icon(CupertinoIcons.search),
                    label: 'Search',
                    icon: Icon(CupertinoIcons.search),
                  ),
                  BottomNavigationBarItem(
                    label: 'Library',
                    activeIcon: Icon(CupertinoIcons.music_albums),
                    icon: Icon(CupertinoIcons.music_albums),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOffstageNavigator(MainController con, String tabItem) {
    return Offstage(
      offstage: _currentPage != tabItem,
      child: TabNavigator(
        con: con,
        navigatorKey: _navigatorKeys[tabItem]!,
        tabItem: tabItem,
      ),
    );
  }
}

class TabNavigator extends StatelessWidget {
  const TabNavigator({
    Key? key,
    required this.navigatorKey,
    required this.tabItem,
    required this.con,
  }) : super(key: key);
  final GlobalKey<NavigatorState> navigatorKey;
  final String tabItem;
  final MainController con;

  @override
  Widget build(BuildContext context) {
    Widget child = Container();
    if (tabItem == "Page1") {
      child = HomeScreen(con: con);
    } else if (tabItem == "Page2") {
      child = SearchPage(con: con);
    } else if (tabItem == "Page3") {
      child = Library(con: con);
    }

    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (routeSettings) {
        return CupertinoPageRoute(builder: (context) => child);
      },
    );
  }
}

class PlayWidget extends StatelessWidget {
  final MainController con;
  const PlayWidget({
    Key? key,
    required this.con,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return con.player.builderCurrent(builder: (context, playing) {
      final myAudio = con.find(con.audios, playing.audio.assetAudioPath);
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CurrentPlayingSong(
                con: con,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black12,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(6.0),
            boxShadow: kElevationToShadow[9],
          ),
          child: ClipRRect(
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: myAudio.metas.image!.path,
                  width: MediaQuery.of(context).size.width,
                  height: 40,
                  progressIndicatorBuilder: (context, url, l) =>
                      const LoadingImage(),
                  fit: BoxFit.cover,
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: CachedNetworkImage(
                                  imageUrl: myAudio.metas.image!.path,
                                  width: 40,
                                  height: 40,
                                  progressIndicatorBuilder: (context, url, l) =>
                                      const LoadingImage(),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        myAudio.metas.title!,
                                        maxLines: 1,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .copyWith(
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        myAudio.metas.artist!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .copyWith(
                                              color: Colors.grey,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        PlayerBuilder.isPlaying(
                            player: con.player,
                            builder: (context, isPlaying) {
                              return IconButton(
                                padding: const EdgeInsets.all(0),
                                onPressed: () {
                                  con.player.playOrPause();
                                },
                                icon: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              );
                            })
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}