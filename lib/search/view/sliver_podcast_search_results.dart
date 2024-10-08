import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/connectivity_model.dart';
import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/offline_page.dart';
import '../../common/view/progress.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/theme.dart';
import '../../l10n/l10n.dart';
import '../../podcasts/podcast_model.dart';
import '../../podcasts/podcast_utils.dart';
import '../search_model.dart';

class SliverPodcastSearchResults extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  const SliverPodcastSearchResults({super.key});

  @override
  State<SliverPodcastSearchResults> createState() =>
      _SliverPodcastSearchResultsState();
}

class _SliverPodcastSearchResultsState
    extends State<SliverPodcastSearchResults> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    di<PodcastModel>()
        .init(
          updateMessage: context.l10n.newEpisodeAvailable,
        )
        .then((_) => di<SearchModel>().search());
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = watchPropertyValue((ConnectivityModel m) => m.isOnline);

    if (!isOnline) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: OfflineBody(),
      );
    }

    final loading = watchPropertyValue((SearchModel m) => m.loading);

    final searchResultItems =
        watchPropertyValue((SearchModel m) => m.podcastSearchResult?.items);

    if (searchResultItems == null || searchResultItems.isEmpty) {
      return SliverFillNoSearchResultPage(
        icon: loading
            ? const SizedBox.shrink()
            : searchResultItems == null
                ? const AnimatedEmoji(AnimatedEmojis.drum)
                : const AnimatedEmoji(AnimatedEmojis.babyChick),
        message: loading
            ? const Progress()
            : Text(
                searchResultItems == null
                    ? context.l10n.search
                    : context.l10n.noPodcastFound,
              ),
      );
    }

    final loadingFeed = watchPropertyValue((PodcastModel m) => m.loadingFeed);

    return SliverGrid.builder(
      itemCount: searchResultItems.length,
      gridDelegate: audioCardGridDelegate,
      itemBuilder: (context, index) {
        final podcastItem = searchResultItems.elementAt(index);

        final art = podcastItem.artworkUrl600 ?? podcastItem.artworkUrl;
        final image = SafeNetworkImage(
          url: art,
          fit: BoxFit.cover,
          height: audioCardDimension,
          width: audioCardDimension,
        );

        return AudioCard(
          bottom: AudioCardBottom(
            text: podcastItem.collectionName ?? podcastItem.trackName,
          ),
          image: image,
          onPlay: loadingFeed
              ? null
              : () => searchAndPushPodcastPage(
                    context: context,
                    feedUrl: podcastItem.feedUrl,
                    itemImageUrl: art,
                    genre: podcastItem.primaryGenreName,
                    play: true,
                  ),
          onTap: loadingFeed
              ? null
              : () => searchAndPushPodcastPage(
                    context: context,
                    feedUrl: podcastItem.feedUrl,
                    itemImageUrl: art,
                    genre: podcastItem.primaryGenreName,
                    play: false,
                  ),
        );
      },
    );
  }
}
