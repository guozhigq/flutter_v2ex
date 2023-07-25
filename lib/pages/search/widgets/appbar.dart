import 'package:flutter/material.dart';
import 'package:flutter_v2ex/components/search/menu.dart';
import 'package:flutter_v2ex/pages/search/controller.dart';
import 'package:flutter_v2ex/service/i18n_keyword.dart';
import 'package:get/get.dart';

class SAppBar extends StatelessWidget implements PreferredSizeWidget {
  SAppBar({super.key});
  final SSearchController _searchController = Get.put(SSearchController());

  @override
  Size get preferredSize => AppBar().preferredSize + const Offset(0, 50);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 1,
      title: Obx(
        () => TextField(
          controller: _searchController.controller.value,
          autofocus: true,
          focusNode: _searchController.replyContentFocusNode.value,
          textInputAction: TextInputAction.search,
          onChanged: (value) => _searchController.onChange(value),
          decoration: InputDecoration(
            hintText: I18nKeyword.searchPower.tr,
            border: InputBorder.none,
            suffixIcon: _searchController.searchKeyWord.value.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    onPressed: () => _searchController.onClear())
                : null,
          ),
          onSubmitted: (String value) => _searchController.submit(value),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: SearchMenu(
          setSort: _searchController.setSort,
          setOrder: _searchController.setOrder,
          setStartTime: _searchController.setStartTime,
          setEndTime: _searchController.setEndTime,
        ),
      ),
    );
  }
}
