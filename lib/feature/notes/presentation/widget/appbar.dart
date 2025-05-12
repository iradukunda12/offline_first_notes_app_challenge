import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kayko_challenge/core/services/bloc/connectivity_cubit.dart';

class AppBars extends StatelessWidget implements PreferredSizeWidget {
  const AppBars({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        return AppBar(
          toolbarHeight: 90,
          backgroundColor: Colors.black,
          centerTitle: true,
          title: Column(
            children: [
              Text(
                "Quick notes",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.circle,
                    color: state.color,
                    size: 12,
                  ),
                  SizedBox(width: 6),
                  Text(
                    state.status,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  if (state.isSyncing)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(90);
}
