class CheckBoxState {
bool value;
  CheckBoxState({
    this.value = false,
  });

  CheckBoxState copyWith({
    bool? value,
  }) {
    return CheckBoxState(
      value: value ?? this.value,
    );
  }
}
