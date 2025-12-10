import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final Future<void> Function(String city)? onFocusCity;

  const ProfileScreen({
    super.key,
    required this.prefs,
    this.onFocusCity,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  final _interestOptions = const [
    'История',
    'Гастрономия',
    'Море',
    'Горы',
    'Музеи',
    'Шоппинг',
  ];
  Set<String> _interests = {};

  DateTimeRange? _dates;
  int _guests = 2;
  bool _savingProfile = false;
  bool _savingBooking = false;
  List<_Booking> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadBookings();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    _nameCtrl.text = widget.prefs.getString('profile_name') ?? 'Путешественник';
    _emailCtrl.text = widget.prefs.getString('profile_email') ?? '';
    _phoneCtrl.text = widget.prefs.getString('profile_phone') ?? '';
    _interests = {...(widget.prefs.getStringList('profile_interests') ?? [])};
    setState(() {});
  }

  Future<void> _saveProfile() async {
    setState(() => _savingProfile = true);
    await widget.prefs.setString('profile_name', _nameCtrl.text.trim());
    await widget.prefs.setString('profile_email', _emailCtrl.text.trim());
    await widget.prefs.setString('profile_phone', _phoneCtrl.text.trim());
    await widget.prefs.setStringList('profile_interests', _interests.toList());
    setState(() => _savingProfile = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Профиль сохранён')),
    );
  }

  Future<void> _loadBookings() async {
    final raw = widget.prefs.getString('bookings_v1');
    if (raw == null || raw.isEmpty) return;
    final decoded = jsonDecode(raw) as List<dynamic>;
    _bookings = decoded.map((e) => _Booking.fromMap(e)).toList();
    setState(() {});
  }

  Future<void> _persistBookings() async {
    final raw = jsonEncode(_bookings.map((b) => b.toMap()).toList());
    await widget.prefs.setString('bookings_v1', raw);
  }

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _dates ??
          DateTimeRange(
            start: now.add(const Duration(days: 7)),
            end: now.add(const Duration(days: 10)),
          ),
    );
    if (range != null) {
      setState(() => _dates = range);
    }
  }

  Future<void> _addBooking() async {
    final city = _cityCtrl.text.trim();
    if (city.length < 2) {
      _showToast('Укажи город (мин. 2 символа)');
      return;
    }
    if (_dates == null) {
      _showToast('Выбери даты поездки');
      return;
    }
    setState(() => _savingBooking = true);

    final booking = _Booking(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      city: city,
      checkIn: _dates!.start,
      checkOut: _dates!.end,
      guests: _guests,
      note: _noteCtrl.text.trim(),
      status: BookingStatus.active,
      createdAt: DateTime.now(),
    );

    setState(() {
      _bookings.insert(0, booking);
      _cityCtrl.clear();
      _noteCtrl.clear();
      _dates = null;
      _guests = 2;
    });

    await _persistBookings();
    setState(() => _savingBooking = false);
    _showToast('Бронирование создано');

    if (widget.onFocusCity != null) {
      await widget.onFocusCity!(booking.city);
    }
  }

  Future<void> _updateBookingStatus(String id, BookingStatus status) async {
    final idx = _bookings.indexWhere((b) => b.id == id);
    if (idx == -1) return;
    setState(() {
      _bookings[idx] = _bookings[idx].copyWith(status: status);
    });
    await _persistBookings();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  int get _activeCount =>
      _bookings.where((b) => b.status == BookingStatus.active).length;
  int get _upcomingCount => _bookings
      .where((b) => b.checkOut.isAfter(DateTime.now()))
      .length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 12),
              _profileCard(),
              const SizedBox(height: 12),
              _bookingForm(),
              const SizedBox(height: 12),
              _bookingsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: Colors.green.shade700,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _nameCtrl.text.isEmpty ? 'Личный кабинет' : _nameCtrl.text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Активных бронирований: $_activeCount · Предстоящих: $_upcomingCount',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Обновить',
          icon: const Icon(Icons.refresh),
          onPressed: () {
            _loadProfile();
            _loadBookings();
          },
        ),
      ],
    );
  }

  Widget _profileCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Профиль и предпочтения',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Имя / никнейм',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _phoneCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Телефон',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _interestOptions.map((option) {
                final selected = _interests.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: selected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _interests.add(option);
                      } else {
                        _interests.remove(option);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _savingProfile ? null : _saveProfile,
                icon: _savingProfile
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_savingProfile ? 'Сохраняем...' : 'Сохранить'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bookingForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Новое бронирование',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _cityCtrl,
              decoration: const InputDecoration(
                labelText: 'Город / регион',
                hintText: 'Например, Рим или Амальфи',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDates,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(
                      _dates == null
                          ? 'Выбрать даты'
                          : '${_dates!.start.day}.${_dates!.start.month}.${_dates!.start.year} — ${_dates!.end.day}.${_dates!.end.month}.${_dates!.end.year}',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: [
                      const Text('Гостей:'),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _guests > 1
                            ? () => setState(() => _guests--)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('$_guests'),
                      IconButton(
                        onPressed: () => setState(() => _guests++),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Пожелания (опционально)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _savingBooking ? null : _addBooking,
                icon: _savingBooking
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(_savingBooking ? 'Сохраняем...' : 'Создать'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bookingsList() {
    if (_bookings.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: const [
              Icon(Icons.event_busy, color: Colors.grey),
              SizedBox(width: 10),
              Expanded(child: Text('Бронирований пока нет')),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _bookings.map((booking) {
        final isPast = booking.checkOut.isBefore(DateTime.now());
        return Card(
          child: ListTile(
            title: Text(booking.city),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatRange(booking.checkIn, booking.checkOut)),
                if (booking.note.isNotEmpty) Text(booking.note),
                Text('Гостей: ${booking.guests}'),
              ],
            ),
            trailing: Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(booking.status.label),
                  backgroundColor: booking.status.color.withOpacity(0.1),
                  labelStyle: TextStyle(color: booking.status.color),
                ),
                IconButton(
                  tooltip: 'На карту',
                  onPressed: widget.onFocusCity == null
                      ? null
                      : () => widget.onFocusCity!(booking.city),
                  icon: const Icon(Icons.map_outlined),
                ),
                if (booking.status == BookingStatus.active && !isPast)
                  IconButton(
                    tooltip: 'Завершить',
                    onPressed: () =>
                        _updateBookingStatus(booking.id, BookingStatus.done),
                    icon: const Icon(Icons.check_circle_outline),
                  ),
                if (booking.status == BookingStatus.active)
                  IconButton(
                    tooltip: 'Отменить',
                    onPressed: () => _updateBookingStatus(
                        booking.id, BookingStatus.cancelled),
                    icon: const Icon(Icons.cancel_outlined),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatRange(DateTime start, DateTime end) {
    String fmt(DateTime dt) => '${dt.day}.${dt.month}.${dt.year}';
    return '${fmt(start)} — ${fmt(end)}';
  }
}

enum BookingStatus { active, cancelled, done }

class _Booking {
  final String id;
  final String city;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final String note;
  final BookingStatus status;
  final DateTime createdAt;

  const _Booking({
    required this.id,
    required this.city,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.note,
    required this.status,
    required this.createdAt,
  });

  _Booking copyWith({BookingStatus? status}) => _Booking(
        id: id,
        city: city,
        checkIn: checkIn,
        checkOut: checkOut,
        guests: guests,
        note: note,
        status: status ?? this.status,
        createdAt: createdAt,
      );

  Map<String, Object> toMap() => {
        'id': id,
        'city': city,
        'checkIn': checkIn.toIso8601String(),
        'checkOut': checkOut.toIso8601String(),
        'guests': guests,
        'note': note,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory _Booking.fromMap(dynamic data) {
    final map = data as Map<String, dynamic>;
    return _Booking(
      id: map['id'] as String,
      city: map['city'] as String,
      checkIn: DateTime.parse(map['checkIn'] as String),
      checkOut: DateTime.parse(map['checkOut'] as String),
      guests: map['guests'] as int,
      note: (map['note'] as String?) ?? '',
      status: BookingStatus.values
          .firstWhere((e) => e.name == map['status'], orElse: () => BookingStatus.active),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

extension on BookingStatus {
  String get label {
    switch (this) {
      case BookingStatus.active:
        return 'Активно';
      case BookingStatus.cancelled:
        return 'Отменено';
      case BookingStatus.done:
        return 'Завершено';
    }
  }

  Color get color {
    switch (this) {
      case BookingStatus.active:
        return Colors.green.shade700;
      case BookingStatus.cancelled:
        return Colors.red.shade600;
      case BookingStatus.done:
        return Colors.blue.shade700;
    }
  }
}

