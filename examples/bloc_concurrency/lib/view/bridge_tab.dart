import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movable_ball/bloc/index.dart';

/// A generic tab widget for displaying bridge-related information and controls.
class BridgeTab<T extends BaseBridgeBloc> extends StatefulWidget {
  /// Creates a BridgeTab with the given title, description, color, and icon.
  const BridgeTab({
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    super.key,
  });

  /// Creates a BridgeTab with the given title, description, color, and icon.
  final String title;

  /// The title of the tab.
  final String description;

  /// A brief description of the tab's functionality.
  final Color color;

  /// The color used for the tab's theme.
  final String icon;

  @override
  BridgeTabState<T> createState() => BridgeTabState<T>();
}

/// The state for the [BridgeTab] widget, managing the bridge's ball sending
/// and resetting logic.
class BridgeTabState<T extends BaseBridgeBloc> extends State<BridgeTab<T>> {
  /// The counter for the number of balls sent.
  int ballCounter = 1;

  void _sendBall() {
    context.read<T>().add(SendBallEvent(ballCounter));
    ballCounter++;
  }

  void _reset() {
    context.read<T>().add(ResetEvent());
    ballCounter = 1;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<T, BridgeState>(
      builder: (context, state) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Description Card
                Card(
                  elevation: 5,
                  shadowColor: widget.color.withAlpha((0.5 * 255).round()),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '${widget.icon} ${widget.title}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: widget.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Bridge Visualization with Animation
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: widget.color, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      // Bridge
                      Positioned(
                        top: 60,
                        left: 20,
                        right: 20,
                        child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.brown,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Center(
                            child: Text(
                              '🌉 BRIDGE 🌉',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Start platform
                      Positioned(
                        top: 50,
                        left: 0,
                        child: Container(
                          width: 25,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Text(
                                'START',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // End platform
                      Positioned(
                        top: 50,
                        right: 0,
                        child: Container(
                          width: 25,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
                            child: RotatedBox(
                              quarterTurns: 1,
                              child: Text(
                                'END',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Animated balls on bridge
                      ...state.ballsOnBridge.map((ball) {
                        final screenWidth =
                            MediaQuery.of(context).size.width -
                            32 -
                            50; // Account for padding and platforms
                        final leftPosition =
                            25 +
                            (ball.position *
                                (screenWidth -
                                    50)); // 25 = start platform width

                        return AnimatedPositioned(
                          duration: const Duration(milliseconds: 100),
                          top: 40,
                          left: leftPosition,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: ball.color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: ball.color.withAlpha(
                                    (0.5 * 255).round(),
                                  ),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '${ball.id}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),

                      // Dropped balls area
                      if (state.ballsDropped.isNotEmpty)
                        Positioned(
                          bottom: 10,
                          left: 20,
                          right: 20,
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.red.withAlpha((0.1 * 255).round()),
                              border: Border.all(
                                color: Colors.red.withAlpha(
                                  (0.3 * 255).round(),
                                ),
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Text(
                                    'Dropped: ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ...state.ballsDropped
                                    .take(8)
                                    .map(
                                      (ballId) => Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.red.withAlpha(
                                            (0.7 * 255).round(),
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '$ballId',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                if (state.ballsDropped.length > 8)
                                  const Text(
                                    '...',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard(
                      'On Bridge',
                      state.ballsOnBridge.length.toString(),
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Completed',
                      state.ballsCompleted.length.toString(),
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Dropped',
                      state.ballsDropped.length.toString(),
                      Colors.red,
                    ),
                    _buildStatCard(
                      'Total Sent',
                      (ballCounter - 1).toString(),
                      Colors.blue,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _sendBall,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.color,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      child: Text(
                        'Send Ball $ballCounter',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _reset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Text(
                  'Send multiple balls quickly to see the difference!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 20),

                // Completed Balls
                if (state.ballsCompleted.isNotEmpty) ...[
                  const Text(
                    'Balls that reached destination:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    children: state.ballsCompleted
                        .map(
                          (ballId) => Container(
                            margin: const EdgeInsets.all(4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withAlpha(
                                (0.2 * 255).round(),
                              ),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Text('Ball $ballId ✅'),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                // Logs - with constrained height
                Container(
                  height: 200, // Fixed height instead of Expanded
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.list, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Bridge Activity Log',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: state.logs.isEmpty
                            ? const Center(
                                child: Text(
                                  'Send balls to see activity',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: state.logs.length,
                                reverse: true,
                                itemBuilder: (context, index) {
                                  final log =
                                      state.logs[state.logs.length - 1 - index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      log,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20), // Add some bottom padding
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: const TextStyle(fontSize: 8)),
        ],
      ),
    );
  }
}
