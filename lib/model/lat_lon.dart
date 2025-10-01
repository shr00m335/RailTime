class LatLon {
  final double latitude;
  final double longtitude;

  const LatLon(this.latitude, this.longtitude);

  @override
  operator ==(other) =>
      other is LatLon &&
      latitude == other.latitude &&
      longtitude == other.longtitude;

  @override
  int get hashCode => Object.hash(latitude, longtitude);
}
