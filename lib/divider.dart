import 'package:flutter/material.dart';
import 'package:pingadinga/editable_text_field.dart';
import 'package:pingadinga/hover_region.dart';

class PingaDivider extends StatelessWidget {
  final String name;
  final String description;
  final int index;
  final void Function() onDelete;
  final void Function(String newValue) onNameChanged;

  const PingaDivider({
    super.key,
    required this.name,
    required this.index,
    required this.description,
    required this.onDelete,
    required this.onNameChanged,
  });

  @override
  Widget build(BuildContext context) {
    return HoverRegionBuilder(
      builder: (context, isHovering) {
        return Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: EditableTextField(
                    value: name,
                    onChanged: onNameChanged,
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                if (isHovering)
                  Row(
                    children: [
                      ReorderableDragStartListener(
                        index: index,
                        child: Tooltip(
                          message: 'Drag to reorder devices',
                          child: IconButton(
                            icon: Icon(Icons.drag_handle),
                            padding: EdgeInsets.all(0.0),
                            constraints: BoxConstraints(),
                            onPressed: () {},
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Tooltip(
                        message: 'Remove divider',
                        child: IconButton(
                          icon: Icon(Icons.clear),
                          padding: EdgeInsets.only(left: 8.0),
                          constraints: BoxConstraints(),
                          onPressed: onDelete,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
