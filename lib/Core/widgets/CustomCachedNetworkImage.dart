import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CustomCachedNetworkImage extends StatelessWidget {
  CustomCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit,
  });
  BoxFit? fit;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) {
        return const Skeletonizer(
            enabled: true,
            child: SizedBox(
              height: double.infinity,
              width: double.infinity,
            ));
      },
      errorWidget: (context, url, error) {
        return const Icon(Icons.error, color: Colors.red, size: 30);
      },
      fit: fit ?? BoxFit.cover,
    );
  }
}
