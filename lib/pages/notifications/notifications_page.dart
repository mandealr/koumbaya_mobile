import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notifications_provider.dart';
import '../../models/notification.dart';
import '../../constants/app_constants.dart';
import '../../widgets/loading_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    final notificationsProvider = Provider.of<NotificationsProvider>(
      context,
      listen: false,
    );
    await notificationsProvider.loadNotifications(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppConstants.primaryColor,
        elevation: 1,
        foregroundColor: Colors.white,
        actions: [
          Consumer<NotificationsProvider>(
            builder: (context, notificationsProvider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) async {
                  switch (value) {
                    case 'mark_all_read':
                      await notificationsProvider.markAllAsRead();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Toutes les notifications ont été marquées comme lues'),
                          ),
                        );
                      }
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'mark_all_read',
                    child: Row(
                      children: [
                        Icon(Icons.done_all),
                        SizedBox(width: 8),
                        Text('Tout marquer comme lu'),
                      ],
                    ),
                  ),
                ],
                icon: const Icon(Icons.more_vert),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: Consumer<NotificationsProvider>(
          builder: (context, notificationsProvider, child) {
            if (notificationsProvider.isLoading &&
                notificationsProvider.notifications.isEmpty) {
              return const LoadingWidget(
                message: 'Chargement des notifications...',
              );
            }

            if (notificationsProvider.error != null) {
              return ErrorMessageWidget(
                message: notificationsProvider.error!,
                onRetry: _loadNotifications,
              );
            }

            if (notificationsProvider.notifications.isEmpty) {
              return EmptyStateWidget(
                title: 'Aucune notification',
                subtitle: 'Vous n\'avez pas encore de notifications',
                icon: Icons.notifications_none,
                buttonText: 'Actualiser',
                onButtonPressed: _loadNotifications,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: notificationsProvider.notifications.length,
              itemBuilder: (context, index) {
                final notification = notificationsProvider.notifications[index];
                return _buildNotificationCard(
                  context,
                  notification,
                  notificationsProvider,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel notification,
    NotificationsProvider provider,
  ) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      onDismissed: (direction) async {
        await provider.deleteNotification(notification.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Notification "${notification.title}" supprimée'),
              action: SnackBarAction(
                label: 'Annuler',
                onPressed: () {
                  // TODO: Implement undo functionality if needed
                },
              ),
            ),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          side: BorderSide(
            color: notification.isRead 
              ? Colors.transparent 
              : AppConstants.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () async {
            if (!notification.isRead) {
              await provider.markAsRead(notification.id);
            }
            // TODO: Handle navigation based on notification type and data
            _handleNotificationTap(context, notification);
          },
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: notification.colorFromType.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    notification.iconData,
                    color: notification.colorFromType,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notification.isRead 
                                  ? FontWeight.w500 
                                  : FontWeight.w700,
                                color: notification.isRead 
                                  ? Colors.black87 
                                  : AppConstants.primaryColor,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppConstants.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: notification.isRead 
                            ? FontWeight.normal 
                            : FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeago.format(notification.createdAtDateTime, locale: 'fr'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: notification.colorFromType.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getTypeDisplayName(notification.type),
                              style: TextStyle(
                                fontSize: 10,
                                color: notification.colorFromType,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'order':
        return 'COMMANDE';
      case 'lottery':
        return 'TOMBOLA';
      case 'payment':
        return 'PAIEMENT';
      case 'system':
        return 'SYSTÈME';
      case 'promotion':
        return 'PROMO';
      default:
        return type.toUpperCase();
    }
  }

  void _handleNotificationTap(BuildContext context, NotificationModel notification) {
    // Handle navigation based on notification type
    switch (notification.type) {
      case 'order':
        // Navigate to order details if order_id is provided
        if (notification.data?['order_id'] != null) {
          // TODO: Navigate to order details page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Navigation vers la commande à implémenter')),
          );
        }
        break;
      case 'lottery':
        // Navigate to lottery details if lottery_id is provided
        if (notification.data?['lottery_id'] != null) {
          // TODO: Navigate to lottery details page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Navigation vers le tirage spécial à implémenter')),
          );
        }
        break;
      case 'payment':
        // Navigate to transaction history
        // TODO: Navigate to transaction history page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Navigation vers l\'historique des transactions à implémenter')),
        );
        break;
      default:
        // Generic notification - show details in dialog
        _showNotificationDetails(context, notification);
        break;
    }
  }

  void _showNotificationDetails(BuildContext context, NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 16),
            Text(
              'Reçue le ${timeago.format(notification.createdAtDateTime, locale: 'fr')}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
      ),
    );
  }
}