import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/farmer_provider.dart';
import '../../../core/providers/weather_provider.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

/// Premium Weather Screen with farmer-centric data display
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  final TextEditingController _locationController = TextEditingController();
  final FocusNode _locationFocus = FocusNode();

  late AnimationController _fadeController;
  late AnimationController _backgroundController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _backgroundAnimation;

  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _error;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadInitialWeather();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _backgroundAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOutSine),
    );
    _backgroundController.repeat(reverse: true);

    _fadeController.forward();
  }

  void _loadInitialWeather() {
    // Try to load weather for user's district if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final farmer = context.read<FarmerProvider>();
      final district = farmer.selectedDistrict;
      if (district != null && district.isNotEmpty) {
        _locationController.text = district;
        _fetchWeather(district);
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _backgroundController.dispose();
    _locationController.dispose();
    _locationFocus.dispose();
    super.dispose();
  }

  Future<void> _fetchWeather(String location) async {
    if (location.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await WeatherService.instance.getWeatherForecast(location);
      setState(() {
        _weatherData = data;
        _isLoading = false;
        _selectedDayIndex = 0;
      });
      // Sync to the shared WeatherProvider so home screen card stays updated
      if (mounted) {
        context.read<WeatherProvider>().fetchWeather(location, forceRefresh: true);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      body: Stack(
        children: [
          // Animated gradient background
          _buildAnimatedBackground(),

          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App bar
                  SliverToBoxAdapter(
                    child: _buildHeader(l10n),
                  ),

                  // Search bar
                  SliverToBoxAdapter(
                    child: _buildSearchBar(l10n),
                  ),

                  // Content
                  if (_isLoading)
                    SliverToBoxAdapter(
                      child: _buildWeatherSkeleton(),
                    )
                  else if (_error != null)
                    SliverFillRemaining(
                      child: _buildErrorState(l10n),
                    )
                  else if (_weatherData == null)
                    SliverFillRemaining(
                      child: _buildEmptyState(l10n),
                    )
                  else ...[
                    // Weather alerts
                    if (_weatherData!.alerts.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _buildAlertsSection(l10n),
                      ),

                    // Current weather
                    SliverToBoxAdapter(
                      child: _buildCurrentWeatherCard(l10n),
                    ),

                    // Farmer-centric insights
                    SliverToBoxAdapter(
                      child: _buildFarmerInsights(l10n),
                    ),

                    // Spray Advisory
                    SliverToBoxAdapter(
                      child: _buildSprayAdvisory(l10n),
                    ),

                    // 7-day forecast
                    SliverToBoxAdapter(
                      child: _buildForecastSection(l10n),
                    ),

                    // Hourly forecast for selected day
                    SliverToBoxAdapter(
                      child: _buildHourlyForecast(l10n),
                    ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, _) {
        final shift = _backgroundAnimation.value * 0.2;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-0.8 + shift, -1.0),
              end: Alignment(0.8 - shift, 1.0),
              colors: const [
                Color(0xFFE0F7FA),
                Color(0xFFF8FAFA),
                Color(0xFFE8F5E9),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_rounded, size: 22),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.text('weather'),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1C1B1F),
                    letterSpacing: -0.5,
                  ),
                ),
                if (_weatherData != null)
                  Text(
                    '${_weatherData!.location.name}, ${_weatherData!.location.region}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00897B), Color(0xFF26A69A)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00897B).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _locationController,
                focusNode: _locationFocus,
                textInputAction: TextInputAction.search,
                onSubmitted: _fetchWeather,
                decoration: InputDecoration(
                  hintText: l10n.text('enter_district_name'),
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.location_on_rounded,
                    color: Colors.grey[400],
                    size: 22,
                  ),
                  suffixIcon: _locationController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                          onPressed: () {
                            _locationController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _locationFocus.unfocus();
              _fetchWeather(_locationController.text);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00897B), Color(0xFF26A69A)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00897B).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.search_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF00897B).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_queue_rounded,
              size: 64,
              color: const Color(0xFF00897B).withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.text('search_weather_location'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1B1F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.text('enter_district_for_forecast'),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.text('weather_error'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1B1F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? l10n.text('unknown_error'),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _fetchWeather(_locationController.text),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.text('retry')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsSection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            l10n.text('weather_alerts'),
            Icons.warning_amber_rounded,
            const Color(0xFFFF5722),
          ),
          const SizedBox(height: 12),
          ..._weatherData!.alerts.map((alert) => _buildAlertCard(alert, l10n)),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Alert alert, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: alert.severityColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: alert.severityColor.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showAlertDetails(alert, l10n),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: alert.severityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.warning_rounded,
                    color: alert.severityColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: alert.severityColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              alert.severity.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: alert.severityColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        alert.event.isNotEmpty ? alert.event : alert.headline,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1B1F),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAlertDetails(Alert alert, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: alert.severityColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.warning_rounded,
                            color: alert.severityColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                alert.event.isNotEmpty ? alert.event : l10n.text('weather_alert'),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1C1B1F),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: alert.severityColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${alert.severity} - ${alert.urgency}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: alert.severityColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (alert.headline.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        alert.headline,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1C1B1F),
                        ),
                      ),
                    ],
                    if (alert.desc.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        alert.desc,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                    if (alert.instruction.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00897B).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: const Color(0xFF00897B),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.text('instructions'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF00897B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              alert.instruction,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard(AppLocalizations l10n) {
    final current = _weatherData!.current;
    final isDay = current.isDay == 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDay
                ? const [Color(0xFF00897B), Color(0xFF26A69A), Color(0xFF4DB6AC)]
                : const [Color(0xFF37474F), Color(0xFF455A64), Color(0xFF546E7A)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: (isDay ? const Color(0xFF00897B) : const Color(0xFF37474F))
                  .withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                right: -30,
                top: -30,
                child: Icon(
                  _getWeatherIcon(current.condition.code, isDay),
                  size: 180,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            _getWeatherIcon(current.condition.code, isDay),
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                current.condition.text,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                l10n.text('feels_like_temp').replaceAll('{temp}', '${current.feelsLikeC.round()}'),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${current.tempC.round()}',
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            '°C',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (_weatherData!.forecast.forecastDays.isNotEmpty) ...[
                              Text(
                                'H: ${_weatherData!.forecast.forecastDays[0].day.maxTempC.round()}°',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                              Text(
                                'L: ${_weatherData!.forecast.forecastDays[0].day.minTempC.round()}°',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Weather metrics grid
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMetricItem(
                            Icons.water_drop_rounded,
                            '${current.humidity}%',
                            l10n.text('humidity'),
                          ),
                          _buildMetricDivider(),
                          _buildMetricItem(
                            Icons.air_rounded,
                            '${current.windKph.round()} km/h',
                            l10n.text('wind'),
                          ),
                          _buildMetricDivider(),
                          _buildMetricItem(
                            Icons.umbrella_rounded,
                            '${current.precipMm} mm',
                            l10n.text('rainfall'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }

  Widget _buildFarmerInsights(AppLocalizations l10n) {
    final current = _weatherData!.current;
    final today = _weatherData!.forecast.forecastDays.isNotEmpty
        ? _weatherData!.forecast.forecastDays[0]
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            l10n.text('farmer_insights'),
            Icons.agriculture_rounded,
            const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildInsightRow(
                  icon: Icons.water_drop_rounded,
                  iconColor: const Color(0xFF2196F3),
                  title: l10n.text('rainfall_forecast'),
                  value: today != null
                      ? '${today.day.totalPrecipMm} mm'
                      : '${current.precipMm} mm',
                  subtitle: today != null
                      ? '${today.day.dailyChanceOfRain}% ${l10n.text('chance_of_rain')}'
                      : '',
                  isFirst: true,
                ),
                _buildDivider(),
                _buildInsightRow(
                  icon: Icons.thermostat_rounded,
                  iconColor: const Color(0xFFFF5722),
                  title: l10n.text('temperature_range'),
                  value: today != null
                      ? '${today.day.minTempC.round()}° - ${today.day.maxTempC.round()}°C'
                      : '${current.tempC.round()}°C',
                  subtitle: _getTemperatureAdvice(today?.day.avgTempC ?? current.tempC, l10n),
                ),
                _buildDivider(),
                _buildInsightRow(
                  icon: Icons.air_rounded,
                  iconColor: const Color(0xFF9C27B0),
                  title: l10n.text('wind_conditions'),
                  value: '${current.windKph.round()} km/h ${current.windDir}',
                  subtitle: _getWindAdvice(current.windKph, l10n),
                ),
                _buildDivider(),
                _buildInsightRow(
                  icon: Icons.opacity_rounded,
                  iconColor: const Color(0xFF00BCD4),
                  title: l10n.text('humidity_level'),
                  value: '${current.humidity}%',
                  subtitle: _getHumidityAdvice(current.humidity, l10n),
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        isFirst ? 16 : 12,
        16,
        isLast ? 16 : 12,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1B1F),
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: Colors.grey.withValues(alpha: 0.15),
      ),
    );
  }

  String _getTemperatureAdvice(double temp, AppLocalizations l10n) {
    if (temp < 10) return l10n.text('temp_advice_cold');
    if (temp < 25) return l10n.text('temp_advice_ideal');
    if (temp < 35) return l10n.text('temp_advice_warm');
    return l10n.text('temp_advice_hot');
  }

  String _getWindAdvice(double windKph, AppLocalizations l10n) {
    if (windKph < 20) return l10n.text('wind_advice_calm');
    if (windKph < 40) return l10n.text('wind_advice_moderate');
    return l10n.text('wind_advice_strong');
  }

  String _getHumidityAdvice(int humidity, AppLocalizations l10n) {
    if (humidity < 40) return l10n.text('humidity_advice_low');
    if (humidity < 70) return l10n.text('humidity_advice_optimal');
    return l10n.text('humidity_advice_high');
  }

  Widget _buildForecastSection(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            l10n.text('seven_day_forecast'),
            Icons.calendar_today_rounded,
            const Color(0xFF3F51B5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _weatherData!.forecast.forecastDays.length,
              itemBuilder: (context, index) {
                final day = _weatherData!.forecast.forecastDays[index];
                final isSelected = _selectedDayIndex == index;
                return _buildForecastDayCard(day, index, isSelected, l10n);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastDayCard(
    ForecastDay day,
    int index,
    bool isSelected,
    AppLocalizations l10n,
  ) {
    final dateTime = day.dateTime;
    final dayName = index == 0
        ? l10n.text('today')
        : DateFormat('EEE').format(dateTime);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedDayIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(right: 12, left: index == 0 ? 0 : 0),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF00897B), Color(0xFF26A69A)],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF00897B).withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: isSelected ? 16 : 8,
              offset: Offset(0, isSelected ? 6 : 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Icon(
              _getWeatherIcon(day.day.condition.code, true),
              color: isSelected ? Colors.white : const Color(0xFF00897B),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              '${day.day.maxTempC.round()}°',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF1C1B1F),
              ),
            ),
            Text(
              '${day.day.minTempC.round()}°',
              style: TextStyle(
                fontSize: 13,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.8)
                    : Colors.grey[500],
              ),
            ),
            if (day.day.dailyChanceOfRain > 20) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.water_drop,
                    size: 10,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.9)
                        : const Color(0xFF2196F3),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${day.day.dailyChanceOfRain}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.9)
                          : const Color(0xFF2196F3),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyForecast(AppLocalizations l10n) {
    if (_selectedDayIndex >= _weatherData!.forecast.forecastDays.length) {
      return const SizedBox.shrink();
    }

    final selectedDay = _weatherData!.forecast.forecastDays[_selectedDayIndex];
    final now = DateTime.now();
    final isToday = _selectedDayIndex == 0;

    // Filter hours for today to show only upcoming hours
    final hours = isToday
        ? selectedDay.hours.where((h) => h.dateTime.hour >= now.hour).toList()
        : selectedDay.hours;

    if (hours.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            l10n.text('hourly_forecast'),
            Icons.schedule_rounded,
            const Color(0xFF607D8B),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: hours.take(12).map((hour) {
                  return _buildHourItem(hour, l10n);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourItem(HourForecast hour, AppLocalizations l10n) {
    final timeStr = DateFormat('ha').format(hour.dateTime);

    return Container(
      margin: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          Text(
            timeStr,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Icon(
            _getWeatherIcon(hour.condition.code, hour.dateTime.hour > 6 && hour.dateTime.hour < 18),
            color: const Color(0xFF00897B),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            '${hour.tempC.round()}°',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1B1F),
            ),
          ),
          if (hour.chanceOfRain > 20) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.water_drop,
                  size: 10,
                  color: Color(0xFF2196F3),
                ),
                const SizedBox(width: 2),
                Text(
                  '${hour.chanceOfRain}%',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Spray Advisory ───────────────────────────────────────────────────────────
  Widget _buildSprayAdvisory(AppLocalizations l10n) {
    final current = _weatherData!.current;
    final today = _weatherData!.forecast.forecastDays.isNotEmpty
        ? _weatherData!.forecast.forecastDays[0]
        : null;

    final windKph = current.windKph;
    final humidity = current.humidity;
    final rainChance = today?.day.dailyChanceOfRain ?? 0;

    // Determine advisory level
    final String status;
    final String title;
    final String description;
    final Color cardColor;
    final Color borderColor;
    final IconData statusIcon;

    if (windKph > 20 || rainChance > 50) {
      status = 'avoid';
      title = l10n.text('spray_avoid');
      description = l10n.text('spray_avoid_desc');
      cardColor = const Color(0xFFFFEBEE);
      borderColor = const Color(0xFFE53935);
      statusIcon = Icons.do_not_disturb_on_rounded;
    } else if (windKph > 12 || humidity > 80 || humidity < 35) {
      status = 'caution';
      title = l10n.text('spray_caution');
      description = l10n.text('spray_caution_desc');
      cardColor = const Color(0xFFFFF8E1);
      borderColor = const Color(0xFFFF8F00);
      statusIcon = Icons.warning_amber_rounded;
    } else {
      status = 'good';
      title = l10n.text('spray_good');
      description = l10n.text('spray_good_desc');
      cardColor = const Color(0xFFE8F5E9);
      borderColor = const Color(0xFF43A047);
      statusIcon = Icons.check_circle_rounded;
    }

    final iconColor = status == 'avoid'
        ? const Color(0xFFE53935)
        : status == 'caution'
            ? const Color(0xFFFF8F00)
            : const Color(0xFF43A047);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            l10n.text('spray_advisory'),
            Icons.water_drop_rounded,
            const Color(0xFF0288D1),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor.withValues(alpha: 0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.10),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(statusIcon, color: iconColor, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: iconColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Conditions row
                        Row(
                          children: [
                            _buildSprayConditionChip(
                              '💨 ${windKph.round()} km/h',
                              windKph > 20
                                  ? const Color(0xFFE53935)
                                  : windKph > 12
                                      ? const Color(0xFFFF8F00)
                                      : const Color(0xFF43A047),
                            ),
                            const SizedBox(width: 8),
                            _buildSprayConditionChip(
                              '💧 $humidity%',
                              humidity > 80 || humidity < 35
                                  ? const Color(0xFFFF8F00)
                                  : const Color(0xFF43A047),
                            ),
                            const SizedBox(width: 8),
                            _buildSprayConditionChip(
                              '🌧️ $rainChance%',
                              rainChance > 50
                                  ? const Color(0xFFE53935)
                                  : rainChance > 30
                                      ? const Color(0xFFFF8F00)
                                      : const Color(0xFF43A047),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSprayConditionChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ── Weather Skeleton ─────────────────────────────────────────────────────────
  Widget _buildWeatherSkeleton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        children: [
          // Main card skeleton
          _WeatherSkeletonBox(height: 220, radius: 28),
          const SizedBox(height: 24),
          // Section header skeleton
          Row(
            children: [
              _WeatherSkeletonBox(width: 36, height: 36, radius: 10),
              const SizedBox(width: 12),
              _WeatherSkeletonBox(width: 160, height: 20, radius: 8),
            ],
          ),
          const SizedBox(height: 16),
          // Insights card skeleton
          _WeatherSkeletonBox(height: 200, radius: 20),
          const SizedBox(height: 24),
          // Forecast header skeleton
          Row(
            children: [
              _WeatherSkeletonBox(width: 36, height: 36, radius: 10),
              const SizedBox(width: 12),
              _WeatherSkeletonBox(width: 140, height: 20, radius: 8),
            ],
          ),
          const SizedBox(height: 16),
          // Forecast cards skeleton
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _WeatherSkeletonBox(width: 80, height: 140, radius: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1B1F),
          ),
        ),
      ],
    );
  }

  IconData _getWeatherIcon(int code, bool isDay) {
    // Weather condition codes from WeatherAPI.com
    if (code == 1000) {
      return isDay ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded;
    } else if (code == 1003) {
      return isDay ? Icons.wb_cloudy : Icons.cloud;
    } else if ([1006, 1009].contains(code)) {
      return Icons.cloud;
    } else if ([1030, 1135, 1147].contains(code)) {
      return Icons.foggy;
    } else if ([1063, 1150, 1153, 1180, 1183].contains(code)) {
      return Icons.grain;
    } else if ([1066, 1114, 1210, 1213, 1216, 1219, 1222, 1225, 1255, 1258].contains(code)) {
      return Icons.ac_unit;
    } else if ([1087, 1273, 1276, 1279, 1282].contains(code)) {
      return Icons.thunderstorm;
    } else if ([1186, 1189, 1192, 1195, 1198, 1201, 1240, 1243, 1246].contains(code)) {
      return Icons.water_drop;
    } else if ([1069, 1072, 1168, 1171, 1204, 1207, 1237, 1249, 1252, 1261, 1264].contains(code)) {
      return Icons.severe_cold;
    }
    return Icons.wb_cloudy;
  }
}

// ── Weather skeleton shimmer box ──────────────────────────────────────────────

class _WeatherSkeletonBox extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;

  const _WeatherSkeletonBox({
    this.width,
    required this.height,
    required this.radius,
  });

  @override
  State<_WeatherSkeletonBox> createState() => _WeatherSkeletonBoxState();
}

class _WeatherSkeletonBoxState extends State<_WeatherSkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            color: Color.lerp(
              const Color(0xFFDCE9E8),
              const Color(0xFFEEF5F5),
              _anim.value,
            ),
          ),
        );
      },
    );
  }
}


