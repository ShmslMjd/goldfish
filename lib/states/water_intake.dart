import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../common/helpers.dart';
import '../database/database_helper.dart';
import '../models/drink_type.dart';
import '../models/tile_color.dart';
import '../models/user_info.dart';
import '../models/water_intake.dart';
import 'daily_total.dart';
import 'intake_bank.dart';

class WaterIntakeNotifier extends StateNotifier<AsyncValue<WaterIntake>> {
  WaterIntakeNotifier(this.read) : super(const AsyncValue.loading()) {
    fetchWaterIntake();
  }

  final Reader read;

  static final dbHelper = DatabaseHelper.instance;

  Future<void> fetchWaterIntake() async {
    final todaysTotalIntakes = await dbHelper.fetchTodaysTotalIntakes();
    final todaysIntakes = await dbHelper.fetchTodaysIntakes();

    await read(dailyTotalProvider.notifier).fetchDailyTotal();

    state = AsyncValue.data(
      WaterIntake(
        todaysTotalIntakes: todaysTotalIntakes,
        todaysIntakes: todaysIntakes,
      ),
    );
  }

  Future<void> insertWaterIntake() async {
    final selectedCup = await dbHelper.getSelectedCup();
    final selectedDrinkType = await dbHelper.getSelectedDrinkType();
    final selectedTileColor = await dbHelper.getSelectedTileColor();

    await dbHelper.insertWaterIntake(
      selectedCup[0]['amount'],
      selectedCup[0]['measurement'],
      selectedDrinkType[0]['drinkTypes'],
      selectedTileColor[0]['tileColors'],
    );

    await fetchWaterIntake();
  }

  Future<void> updateWaterIntakeCup({
    @required int waterIntakeID,
    @required int amount,
    @required LiquidMeasurement measurement,
  }) async {
    await dbHelper.updateWaterIntakeCup(
      waterIntakeID: waterIntakeID,
      amount: amount,
      measurement: measurement.description,
    );

    await fetchWaterIntake();
  }

  Future<void> updateWaterIntakeDate({
    @required int waterIntakeID,
    @required TimeOfDay date,
  }) async {
    await dbHelper.updateWaterIntakeDate(
      waterIntakeID: waterIntakeID,
      date: date.toDateTime.toString(),
    );

    await fetchWaterIntake();
  }

  Future<void> updateWaterIntakeDrinkTypes({
    @required int waterIntakeID,
    @required DrinkTypes drinkTypes,
  }) async {
    await dbHelper.updateWaterIntakeDrinkTypes(
      waterIntakeID: waterIntakeID,
      drinkTypes: drinkTypes.description.toLowerCase(),
    );

    await fetchWaterIntake();
  }

  Future<void> updateWaterIntakeTileColors({
    @required int waterIntakeID,
    @required TileColors tileColors,
  }) async {
    await dbHelper.updateWaterIntakeTileColors(
      waterIntakeID: waterIntakeID,
      tileColors: tileColors.description.toLowerCase(),
    );

    await fetchWaterIntake();
  }

  Future<void> deleteWaterIntake({@required int waterIntakeID}) async {
    await dbHelper.deleteWaterIntake(waterIntakeID: waterIntakeID);

    await fetchWaterIntake();
  }

  Future<bool> hasUserAchievedGoal() async {
    final todaysTotalWaterIntake =
        await dbHelper.fetchTodaysTotalIntakes() ?? 0;
    final hydrationPlan = await dbHelper.fetchHydrationPlan();
    final dailyGoal = hydrationPlan[0]['dailyGoal'] as int;
    final todaysCompletionStatus = await dbHelper.fetchTodaysCompletionStatus();

    if (todaysTotalWaterIntake >= dailyGoal &&
        todaysCompletionStatus.toBool == false) {
      await dbHelper.updateCompletionStatus(true);

      await read(intakeBankProvider.notifier).updateIntakeBank(
        value: dailyGoal.toDouble(),
        arithmeticOperator: '+',
      );

      return true;
    } else {
      return false;
    }
  }
}

final waterIntakeProvider =
    StateNotifierProvider<WaterIntakeNotifier, AsyncValue<WaterIntake>>(
  (ref) => WaterIntakeNotifier(ref.read),
);
