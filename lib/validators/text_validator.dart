import 'package:shopping_list/models/validator_response.dart';

ValidatorResponse validateTextField(String? value) {
  if (value == null || value.isEmpty) {
    return const ValidatorResponse(
      message: 'Field Cannot be empty',
      status: false,
    );
  }

  if (value.trim().length <= 2) {
    return const ValidatorResponse(
      message: 'Field must be minimum of 2 characters',
      status: false,
    );
  }

  if (value.trim().length > 100) {
    return const ValidatorResponse(
      message: "Exceeded the maximum number of characters allowed",
      status: false,
    );
  }

  return const ValidatorResponse(
    status: true,
    message: 'Validated',
  );
}

ValidatorResponse validateNumberField(String? value) {
  if (value == null || value.isEmpty) {
    return const ValidatorResponse(
      message: 'Field Cannot be empty',
      status: false,
    );
  }

  if (int.tryParse(value) == null) {
    return const ValidatorResponse(
      status: false,
      message: 'Quantity is a number!',
    );
  }

  if (int.parse(value) <= 0) {
    return const ValidatorResponse(
      status: false,
      message: 'Quantity must be positive!',
    );
  }

  return const ValidatorResponse(
    status: true,
    message: 'Validated',
  );
}
