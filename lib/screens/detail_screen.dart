import 'package:flutter/material.dart';

import 'package:flutter_toon/models/webtoon_detail_model.dart';
import 'package:flutter_toon/models/webtoon_episode_model.dart';
import 'package:flutter_toon/widgets/episode_widget.dart';
import 'package:flutter_toon/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends StatefulWidget {
  final String title, thumb, id;

  const DetailScreen({
    super.key,
    required this.title,
    required this.thumb,
    required this.id,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<WebtoonDetailModel> webtoon;
  late Future<List<WebtoonEpisodeModel>> episodes;
  late SharedPreferences prefs;
  bool isLiked = false;

  // prefs = { likedToons: [] };
  Future initPerfs() async {
    prefs = await SharedPreferences.getInstance();
    final likedToons = prefs.getStringList('likedToons');
    if (likedToons != null) {
      setState(() {
        likedToons.contains(widget.id) ? isLiked = true : isLiked = false;
      });
    } else {
      prefs.setStringList('likedToons', []);
    }
  }

  onHeartTap() async {
    final likedToons = prefs.getStringList('likedToons');
    if (likedToons != null) {
      if (isLiked) {
        likedToons.remove(widget.id);
      } else {
        likedToons.add(widget.id);
      }
      await prefs.setStringList('likedToons', likedToons);
      setState(() {
        isLiked = !isLiked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    webtoon = ApiService.getTodayToonById(widget.id);
    episodes = ApiService.getLatestEpisodesById(widget.id);
    initPerfs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
        title: Text(widget.title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400)),
        actions: [
          IconButton(
            onPressed: onHeartTap,
            icon:
                Icon(isLiked ? Icons.favorite_rounded : Icons.favorite_outline),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: widget.id,
                    child: Container(
                      width: 200,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 5,
                            offset: const Offset(5, 5),
                            color: Colors.grey.withOpacity(0.5),
                          ),
                        ],
                      ),
                      child: Image.network(
                        widget.thumb,
                        headers: const {
                          'Referer': 'https://comic.naver.com',
                        },
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              FutureBuilder(
                  future: webtoon,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(snapshot.data!.about,
                              style: TextStyle(fontSize: 12)),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                              '${snapshot.data!.genre} / ${snapshot.data!.age}',
                              style: TextStyle(fontSize: 12))
                        ],
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: Text('Loading...'),
                      );
                    }
                  }),
              SizedBox(height: 10),
              FutureBuilder(
                  future: episodes,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          for (var episode in snapshot.data!)
                            Episode(webtoonId: widget.id, episode: episode)
                        ],
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }
}
