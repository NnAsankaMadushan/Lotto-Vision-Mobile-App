import 'package:dartz/dartz.dart';
import 'package:lotto_vision/core/constants/lottery_types.dart';
import 'package:lotto_vision/core/utils/typedefs.dart';
import 'package:lotto_vision/domain/entities/lottery_prediction.dart';
import 'package:lotto_vision/domain/repositories/lottery_repository.dart';
import 'package:lotto_vision/services/lottery/lottery_prediction_engine.dart';

class GeneratePredictions {
  final LotteryRepository repository;
  final LotteryPredictionEngine engine;

  const GeneratePredictions(
    this.repository,
    this.engine,
  );

  ResultFuture<PredictionResult> call({
    required LotteryType type,
    int sets = 5,
    int maxHistory = 60,
    int? seed,
  }) async {
    final resultsEither = await repository.getAllResults();
    return resultsEither.fold(
      (failure) => Left(failure),
      (results) {
        final prediction = engine.generate(
          type: type,
          history: results,
          sets: sets,
          maxHistory: maxHistory,
          seed: seed,
        );
        return Right(prediction);
      },
    );
  }
}
