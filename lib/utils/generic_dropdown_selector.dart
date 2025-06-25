import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:skeletonizer/skeletonizer.dart';

class AsyncDropdownSelector<T> extends ConsumerStatefulWidget
    with AsyncBottomSheetAction {
  final String hintText;
  final String subTitle;
  final String? Function(String?)? validator;
  final AutoDisposeFutureProvider<List<T>> itemsProvider;
  final bool Function(T, String) filter;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? customEmptyWidget;
  final Widget Function(BuildContext context)? extraTopItemBuilder;
  final TextEditingController textEditingController;
  // Add these new properties
  final FocusNode? focusNode;
  final Function(String)? onFieldSubmitted;
  final TextStyle? subTitleTextStyle;
  final Color? suffixIconColor;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final bool? showSubtitle;

  const AsyncDropdownSelector(
      {super.key,
      required this.hintText,
      required this.subTitle,
      this.subTitleTextStyle = const TextStyle(
        fontSize: 12,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      this.suffixIconColor = Colors.black,
      this.border,
      this.enabledBorder,
      this.textStyle = const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      this.hintStyle,
      this.validator,
      required this.itemsProvider,
      required this.filter,
      required this.itemBuilder,
      this.customEmptyWidget,
      this.extraTopItemBuilder,
      required this.textEditingController,
      // Add these to the constructor
      this.focusNode,
      this.onFieldSubmitted,
      this.showSubtitle = true});

  @override
  ConsumerState<AsyncDropdownSelector> createState() =>
      AsyncDropdownSelectorState<T>();
}

class AsyncDropdownSelectorState<T>
    extends ConsumerState<AsyncDropdownSelector<T>> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController textEditingController;
  String? _errorText;

  @override
  void initState() {
    textEditingController = widget.textEditingController;
    textEditingController.addListener(_validateOnChange);
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.removeListener(_validateOnChange);
    super.dispose();
  }

  void _validateOnChange() {
    setState(() {
      _errorText = widget.validator?.call(textEditingController.text);
    });
  }

  bool validate() {
    setState(() {
      _errorText = widget.validator?.call(textEditingController.text);
    });
    return _errorText == null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await widget.showCustomFutureListBottomsheet<T>(
          context: context,
          itemBuilder: widget.itemBuilder,
          listProvider: widget.itemsProvider,
          filter: widget.filter,
        );
        validate();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showSubtitle ?? true)
            Text(widget.subTitle, style: widget.subTitleTextStyle),
          SizedBox(height: 8),
          IntrinsicHeight(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AbsorbPointer(
                    child: TextFormField(
                      controller: textEditingController,
                      style: widget.textStyle,
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: widget.hintStyle,
                        alignLabelWithHint: true,
                        suffixIcon: Icon(
                          Icons.keyboard_arrow_down_outlined,
                          color: widget.suffixIconColor,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        errorText: _errorText,
                        border: widget.border,
                        enabledBorder: widget.enabledBorder,
                      ),
                      readOnly: true,
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
}

mixin AsyncBottomSheetAction {
  Future<void> showCustomFutureListBottomsheet<T>({
    required BuildContext context,
    required Widget Function(BuildContext context, T item, int index)
        itemBuilder,
    required AutoDisposeFutureProvider<List<T>> listProvider,
    required bool Function(T, String) filter,
    Widget? customEmptyWidget,
    Widget Function(BuildContext context)? extraTopItemBuilder,
  }) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // Add this to ensure the bottom sheet resizes with keyboard
      useSafeArea: true,
      builder: (context) {
        // Wrap with Padding to handle keyboard
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: CustomBottomSheet<T>(
            itemBuilder: itemBuilder,
            listProvider: listProvider,
            filter: filter,
            customEmptyWidget: customEmptyWidget,
            extraTopItemBuilder: extraTopItemBuilder,
          ),
        );
      },
    );
    log("Sheet Dismissed");
  }
}

class CustomBottomSheet<T> extends ConsumerWidget {
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final AutoDisposeFutureProvider<List<T>> listProvider;
  final bool Function(T, String) filter;
  final Widget? customEmptyWidget;
  final Widget Function(BuildContext context)? extraTopItemBuilder;

  const CustomBottomSheet({
    super.key,
    required this.itemBuilder,
    required this.listProvider,
    required this.filter,
    this.customEmptyWidget,
    this.extraTopItemBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      // Adjust initial size to be smaller when keyboard is visible
      initialChildSize:
          MediaQuery.of(context).viewInsets.bottom > 0 ? 0.9 : 0.6,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              Expanded(
                child: SearchableListView<T>(
                  itemBuilder: itemBuilder,
                  listProvider: listProvider,
                  filter: filter,
                  customEmptyWidget: customEmptyWidget,
                  extraTopItemBuilder: extraTopItemBuilder,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SearchableListView<T> extends ConsumerWidget {
  const SearchableListView({
    super.key,
    required this.itemBuilder,
    required this.listProvider,
    required this.filter,
    this.customEmptyWidget,
    this.extraTopItemBuilder,
  });

  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final AutoDisposeFutureProvider<List<T>> listProvider;
  final bool Function(T, String) filter;
  final Widget? customEmptyWidget;
  final Widget Function(BuildContext context)? extraTopItemBuilder;

  Future<void> _refresh(WidgetRef refreshRef) async {
    return refreshRef.refresh(listProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(listProvider);
    final searchQuery = ref.watch(_searchQueryProvider);
    final width = MediaQuery.sizeOf(context).width;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Skeletonizer(
            enabled: dataAsync.isLoading,
            child: TextField(
              autofocus: false,
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
              ),
              onChanged: (value) =>
                  ref.read(_searchQueryProvider.notifier).search(value),
            ),
          ),
        ),
        Expanded(
          child: dataAsync.when(
            data: (data) {
              if (dataAsync.isRefreshing) {
                return SizedBox(
                  height: width,
                  child: const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                );
              }

              final filteredData =
                  data.where((item) => filter(item, searchQuery)).toList();

              if (filteredData.isEmpty && extraTopItemBuilder == null) {
                return Center(
                    child: customEmptyWidget ?? const Text("Not found"));
              } else {
                return RefreshIndicator(
                  onRefresh: () => _refresh(ref),
                  child: ListView.separated(
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      color: Colors.black12,
                    ),
                    itemCount: filteredData.length +
                        (extraTopItemBuilder != null ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == 0 && extraTopItemBuilder != null) {
                        return extraTopItemBuilder!(context);
                      }
                      final dataIndex =
                          extraTopItemBuilder != null ? index - 1 : index;
                      return itemBuilder(
                        context,
                        filteredData[dataIndex],
                        dataIndex,
                      );
                    },
                  ),
                );
              }
            },
            error: (error, s) {
              if (dataAsync.isRefreshing) {
                return SizedBox(
                  height: width,
                  child: const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                );
              }
              return const Text("Failed");
            },
            loading: () => SizedBox(
              height: width,
              child: Skeletonizer(
                enabled: true,
                child: ListView.builder(
                    itemCount: 10,
                    itemBuilder: (b, i) {
                      return ListTile(
                        title: Text(
                          "Loading Data here it is ...........",
                          maxLines: 1,
                        ),
                        subtitle: Text(
                          "Loading Data here it is ...........",
                          maxLines: 1,
                        ),
                      );
                    }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

final _searchQueryProvider =
    StateNotifierProvider.autoDispose<SearchableListViewStateNotifier, String>(
        (ref) {
  return SearchableListViewStateNotifier('');
});

class SearchableListViewStateNotifier extends StateNotifier<String> {
  SearchableListViewStateNotifier(super.state);

  search(String data) {
    state = data;
  }
}
