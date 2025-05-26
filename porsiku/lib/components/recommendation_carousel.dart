import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:porsiku/constants/constants.dart'; // Ensure this path is correct

class RecommendationCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> recommendations;
  final CarouselSliderController carouselController; // Changed type here
  final int currentCarouselIndex;
  final Function(int, CarouselPageChangedReason) onPageChanged;

  const RecommendationCarousel({
    super.key,
    required this.recommendations,
    required this.carouselController, // Type changed here
    required this.currentCarouselIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        CarouselSlider(
          carouselController: carouselController, // Use the passed controller
          options: CarouselOptions(
            height: 200.0, // Adjust height as needed
            autoPlay: false,
            enlargeCenterPage: false,
            viewportFraction: 0.9,
            aspectRatio: 2.0,
            onPageChanged: onPageChanged,
          ),
          items:
              recommendations.map((rec) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        image: DecorationImage(
                          image: AssetImage(rec['image']! as String),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(
                                    AppBorderRadius.md,
                                  ),
                                  bottomRight: Radius.circular(
                                    AppBorderRadius.md,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rec['title']! as String,
                                    style: TextStyle(
                                      fontSize: AppTexts.md,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${rec['calories']}cal',
                                        style: TextStyle(
                                          fontSize: AppTexts.sm,
                                          color: AppColors.white,
                                        ),
                                      ),
                                      Text(
                                        '${rec['protein']}g Prot',
                                        style: TextStyle(
                                          fontSize: AppTexts.sm,
                                          color: AppColors.white,
                                        ),
                                      ),
                                      Text(
                                        '${rec['carbs']}g Carb',
                                        style: TextStyle(
                                          fontSize: AppTexts.sm,
                                          color: AppColors.white,
                                        ),
                                      ),
                                      Text(
                                        '${rec['fat']}g Fat',
                                        style: TextStyle(
                                          fontSize: AppTexts.sm,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (rec['time'] != null)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(
                                    AppBorderRadius.sm,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.timer_outlined,
                                      color: AppColors.white,
                                      size: AppTexts.sm,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      rec['time']! as String,
                                      style: TextStyle(
                                        fontSize: AppTexts.xs,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
        ),
        const SizedBox(height: 8),
        _buildCarouselIndicator(recommendations.length),
      ],
    );
  }

  Widget _buildCarouselIndicator(int itemCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        bool isActive = index == currentCarouselIndex;
        return Container(
          width: isActive ? AppBorderRadius.lg : AppBorderRadius.sm,
          height: AppBorderRadius.sm,
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppBorderRadius.infinity),
            color: isActive ? AppColors.black : AppColors.lightGrey,
          ),
        );
      }),
    );
  }
}
