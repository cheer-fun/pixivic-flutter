import 'package:injectable/injectable.dart';

import 'package:pixivic/common/do/artist.dart';
import 'package:pixivic/common/do/result.dart';
import 'package:pixivic/common/do/illust.dart';
import 'package:pixivic/http/client/artist_rest_client.dart';

@lazySingleton
class ArtistService {
  final ArtistRestClient _artistRestClient;

  ArtistService(this._artistRestClient);

  processArtistData(List data) {
    List<Artist> artistList = [];
    data.map((s) => Artist.fromJson(s)).forEach((e) {
      artistList.add(e);
    });
    return artistList;
  }

  processIllustData(List data) {
    List<Illust> illustList = [];
    data.map((s) => Illust.fromJson(s)).forEach((e) {
      illustList.add(e);
    });
    return illustList;
  }

  Future<Result<List<Illust>>> queryArtistIllustList(
      int artistId, String type, int page, int pageSize, int maxSanityLevel) {
    return _artistRestClient
        .queryArtistIllustListInfo(
            artistId, type, page, pageSize, maxSanityLevel)
        .then((value) {
      if (value.data != null) value.data = processIllustData(value.data);
      return value;
    });
  }

  Future<Result<Artist>> querySearchArtistById(int artistId) {
    return _artistRestClient.querySearchArtistByIdInfo(artistId).then((value) {
      if (value.data != null) value.data = Artist.fromJson(value.data);
      return value;
    });
  }

  Future<Result<ArtistSummary>> queryArtistIllustSummary(int artistId) {
    return _artistRestClient
        .queryArtistIllustSummaryInfo(artistId)
        .then((value) {
      if (value.data != null) value.data = ArtistSummary.fromJson(value.data);
      return value;
    });
  }

  Future<Result<List<Artist>>> querySearchArtist(
      String artistName, int page, int pageSize) {
    return _artistRestClient
        .querySearchArtistInfo(artistName, page, pageSize)
        .then((value) {
      if (value.data != null) value.data = processArtistData(value.data);
      return value;
    });
  }
}
