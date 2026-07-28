// lib/presentation/screens/exercise_library/widgets/exercise_search_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymgenius/presentation/blocs/exercise_library/exercise_library_bloc.dart';
import 'package:gymgenius/presentation/blocs/exercise_library/exercise_library_event.dart';

class ExerciseSearchBar extends StatefulWidget {
  const ExerciseSearchBar({super.key});

  @override
  State<ExerciseSearchBar> createState() => _ExerciseSearchBarState();
}

class _ExerciseSearchBarState extends State<ExerciseSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search exercises...',
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withAlpha(153),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: colorScheme.onSurface.withAlpha(153),
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: colorScheme.onSurface.withAlpha(153),
                  ),
                  onPressed: () {
                    _controller.clear();
                    context
                        .read<ExerciseLibraryBloc>()
                        .add(const ExerciseLibrarySearchChanged(''));
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: (value) {
          context
              .read<ExerciseLibraryBloc>()
              .add(ExerciseLibrarySearchChanged(value));
          setState(() {});
        },
      ),
    );
  }
}
