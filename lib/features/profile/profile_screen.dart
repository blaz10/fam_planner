import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_localizations.dart';
import '../../../models/household_member.dart';
import '../../../services/database_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  Color _selectedColor = Colors.blue;
  
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }
  
  Future<void> _loadProfile() async {
    try {
      final members = await _databaseService.getHouseholdMembers();
      if (members.isNotEmpty) {
        final member = members.first;
        setState(() {
          _nameController.text = member.name;
          _emailController.text = member.email ?? '';
          _phoneController.text = member.phone ?? '';
          _selectedColor = Color(member.colorValue);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('profile')),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfilePicture(),
              const SizedBox(height: 24.0),
              _buildNameField(),
              const SizedBox(height: 16.0),
              _buildEmailField(),
              const SizedBox(height: 16.0),
              _buildPhoneField(),
              const SizedBox(height: 24.0),
              _buildColorPicker(),
              const SizedBox(height: 32.0),
              _buildStatistics(),
              const SizedBox(height: 32.0),
              _buildLogoutButton(theme),
              const SizedBox(height: 24.0),
              _buildThemeToggle(themeProvider, theme),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120.0,
            height: 120.0,
            decoration: BoxDecoration(
              color: _selectedColor.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: _selectedColor,
                width: 2.0,
              ),
            ),
            child: Center(
              child: Text(
                _nameController.text.isNotEmpty 
                    ? _nameController.text[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 48.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit,
                color: _selectedColor,
                size: 20.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.translate('name'),
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.translate('name_required');
        }
        return null;
      },
    );
  }
  
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.translate('email'),
        prefixIcon: const Icon(Icons.email),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }
  
  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.translate('phone'),
        prefixIcon: const Icon(Icons.phone),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      keyboardType: TextInputType.phone,
    );
  }
  
  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.translate('choose_color'),
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          height: 60.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.profileColors.length,
            itemBuilder: (context, index) {
              final color = AppConstants.profileColors[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: Container(
                  width: 50.0,
                  height: 50.0,
                  margin: const EdgeInsets.only(right: 8.0),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedColor == color ? Colors.black : Colors.transparent,
                      width: 2.0,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatistics() {
    return FutureBuilder<Map<String, int>>(
      future: _getStatistics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final stats = snapshot.data ?? {
          'tasks': 0,
          'completed': 0,
          'shopping': 0,
          'bought': 0,
        };
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.translate('statistics'),
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  '${stats['tasks']}',
                  AppLocalizations.of(context)!.translate('total_tasks'),
                  Icons.task,
                ),
                _buildStatCard(
                  '${stats['completed']}',
                  AppLocalizations.of(context)!.translate('completed'),
                  Icons.check_circle,
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  '${stats['shopping']}',
                  AppLocalizations.of(context)!.translate('shopping_items'),
                  Icons.shopping_cart,
                ),
                _buildStatCard(
                  '${stats['bought']}',
                  AppLocalizations.of(context)!.translate('bought'),
                  Icons.check_circle_outline,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildStatCard(String value, String label, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2.0,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(icon, size: 32.0, color: _selectedColor),
              const SizedBox(height: 8.0),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildThemeToggle(ThemeProvider themeProvider, ThemeData theme) {
    return Card(
      child: SwitchListTile(
        title: const Text('Dark Mode'),
        subtitle: Text(themeProvider.isDarkMode ? 'On' : 'Off'),
        value: themeProvider.isDarkMode,
        onChanged: (value) {
          themeProvider.toggleTheme();
        },
        secondary: Icon(
          themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
  
  Widget _buildLogoutButton(ThemeData theme) {
    return ElevatedButton(
      onPressed: _confirmLogout,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.error,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(
        AppLocalizations.of(context)!.translate('logout').toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
  
  Future<Map<String, int>> _getStatistics() async {
    final tasks = await _databaseService.getTasks();
    final shoppingItems = await _databaseService.getShoppingItems();
    
    return {
      'tasks': tasks.length,
      'completed': tasks.where((task) => task.isDone).length,
      'shopping': shoppingItems.length,
      'bought': shoppingItems.where((item) => item.isBought).length,
    };
  }
  
  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Check if we already have a member
        final members = await _databaseService.getHouseholdMembers();
        HouseholdMember member;
        
        if (members.isNotEmpty) {
          // Update existing member
          member = members.first.copyWith(
            name: _nameController.text,
            email: _emailController.text.isNotEmpty ? _emailController.text : null,
            phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
            color: _selectedColor,
          );
        } else {
          // Create new member
          member = HouseholdMember(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: _nameController.text,
            email: _emailController.text.isNotEmpty ? _emailController.text : null,
            phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
            color: _selectedColor,
          );
        }
        
        await _databaseService.saveHouseholdMember(member);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.translate('profile_updated')),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  
  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate('confirm_logout')),
        content: Text(AppLocalizations.of(context)!.translate('logout_confirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.translate('logout')),
          ),
        ],
      ),
    ) ?? false;
    
    if (confirmed && mounted) {
      // TODO: Implement logout logic
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}
