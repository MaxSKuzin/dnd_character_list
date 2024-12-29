class CreateItemController {
  CreateItemPresenter? _presenter;

  CreateItemController(this._presenter);

  dynamic createItem() => _presenter!.createItem();

  void dispose() {
    _presenter = null;
  }
}

mixin CreateItemPresenter<T> {
  T createItem();
}
