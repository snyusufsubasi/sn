package com.araciyok.nativeapp.ui

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.animation.slideOutVertically
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.AccountCircle
import androidx.compose.material.icons.outlined.ChatBubbleOutline
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Inventory2
import androidx.compose.material.icons.outlined.Notifications
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.araciyok.nativeapp.data.DemoViewModel
import com.araciyok.nativeapp.model.Role
import com.araciyok.nativeapp.ui.components.AnimatedBadge
import com.araciyok.nativeapp.ui.screens.AuthScreen
import com.araciyok.nativeapp.ui.screens.CarrierHomeScreen
import com.araciyok.nativeapp.ui.screens.CarrierJobsScreen
import com.araciyok.nativeapp.ui.screens.ChatScreen
import com.araciyok.nativeapp.ui.screens.JobDetailScreen
import com.araciyok.nativeapp.ui.screens.MessagesScreen
import com.araciyok.nativeapp.ui.screens.MyJobsScreen
import com.araciyok.nativeapp.ui.screens.NotificationsScreen
import com.araciyok.nativeapp.ui.screens.ProfileScreen
import com.araciyok.nativeapp.ui.screens.ShipperHomeScreen
import com.araciyok.nativeapp.ui.theme.Accent
import com.araciyok.nativeapp.ui.theme.AraciyokTheme
import com.araciyok.nativeapp.ui.theme.Background
import com.araciyok.nativeapp.ui.theme.Border
import com.araciyok.nativeapp.ui.theme.Navy
import com.araciyok.nativeapp.ui.theme.Success
import kotlinx.coroutines.delay

@Composable
fun AraciyokApp(vm: DemoViewModel = viewModel()) {
    AraciyokTheme {
        Surface(Modifier.fillMaxSize(), color = Background) {
            AnimatedContent(
                targetState = vm.isLoggedIn,
                transitionSpec = {
                    (fadeIn() + slideInVertically { it / 8 }) togetherWith
                        (fadeOut() + slideOutVertically { -it / 8 })
                },
                label = "authTransition"
            ) { loggedIn ->
                if (loggedIn) MainShell(vm) else AuthScreen(vm)
            }
        }
    }
}

private data class TabItem(val title: String, val icon: ImageVector)
private data class ScreenKey(val tab: Int, val jobId: String?, val chatUserId: String?)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun MainShell(vm: DemoViewModel) {
    val tabs = remember {
        listOf(
            TabItem("Anasayfa", Icons.Outlined.Home),
            TabItem("İlanlar", Icons.Outlined.Inventory2),
            TabItem("Bildirimler", Icons.Outlined.Notifications),
            TabItem("Mesajlar", Icons.Outlined.ChatBubbleOutline),
            TabItem("Profil", Icons.Outlined.Person)
        )
    }
    val screenKey = ScreenKey(vm.currentTab, vm.selectedJobId, vm.selectedChatUserId)

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        if (vm.role == Role.Shipper) "Yükveren Paneli" else "Nakliyeci Paneli",
                        color = Navy,
                        fontWeight = FontWeight.Black
                    )
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Background),
                actions = {
                    IconButton(onClick = { vm.currentTab = 2; vm.selectedJobId = null; vm.selectedChatUserId = null }) {
                        AnimatedBadge(vm.unreadNotifications) {
                            Icon(Icons.Outlined.Notifications, contentDescription = "Bildirimler", tint = Navy)
                        }
                    }
                    IconButton(onClick = { vm.currentTab = 4; vm.selectedJobId = null; vm.selectedChatUserId = null }) {
                        Icon(Icons.Outlined.AccountCircle, contentDescription = "Profil", tint = Navy)
                    }
                    IconButton(onClick = { vm.currentTab = 4; vm.selectedJobId = null; vm.selectedChatUserId = null }) {
                        Icon(Icons.Outlined.Settings, contentDescription = "Ayarlar", tint = Navy)
                    }
                }
            )
        },
        bottomBar = {
            NavigationBar(containerColor = Background, tonalElevation = 8.dp) {
                tabs.forEachIndexed { index, tab ->
                    val selected = vm.currentTab == index && vm.selectedJobId == null && vm.selectedChatUserId == null
                    NavigationBarItem(
                        selected = selected,
                        onClick = {
                            vm.currentTab = index
                            vm.selectedJobId = null
                            vm.selectedChatUserId = null
                        },
                        icon = {
                            val badge = when (tab.title) {
                                "Bildirimler" -> vm.unreadNotifications
                                "Mesajlar" -> vm.unreadMessages
                                else -> 0
                            }
                            AnimatedBadge(badge) { Icon(tab.icon, contentDescription = tab.title) }
                        },
                        label = { Text(tab.title, fontSize = 11.sp, fontWeight = FontWeight.SemiBold) }
                    )
                }
            }
        }
    ) { padding ->
        Box(
            Modifier
                .padding(padding)
                .background(Background)
                .fillMaxSize()
        ) {
            AnimatedContent(
                targetState = screenKey,
                transitionSpec = {
                    (fadeIn() + slideInHorizontally { it / 10 }) togetherWith
                        (fadeOut() + slideOutHorizontally { -it / 10 })
                },
                label = "screenTransition"
            ) { key ->
                when {
                    key.chatUserId != null -> ChatScreen(vm)
                    key.jobId != null -> JobDetailScreen(vm, key.jobId)
                    vm.role == Role.Shipper && key.tab == 0 -> ShipperHomeScreen(vm)
                    vm.role == Role.Carrier && key.tab == 0 -> CarrierHomeScreen(vm)
                    vm.role == Role.Shipper && key.tab == 1 -> MyJobsScreen(vm)
                    vm.role == Role.Carrier && key.tab == 1 -> CarrierJobsScreen(vm)
                    key.tab == 2 -> NotificationsScreen(vm)
                    key.tab == 3 -> MessagesScreen(vm)
                    else -> ProfileScreen(vm)
                }
            }
            SuccessToast(vm)
        }
    }
}

@Composable
private fun SuccessToast(vm: DemoViewModel) {
    val message = vm.successMessage
    LaunchedEffect(message) {
        if (message != null) {
            delay(2200)
            vm.clearSuccessMessage()
        }
    }
    AnimatedVisibility(
        visible = message != null,
        enter = fadeIn() + slideInVertically(initialOffsetY = { -it }),
        exit = fadeOut() + slideOutVertically(targetOffsetY = { -it }),
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp)
    ) {
        Surface(
            color = Success,
            shape = RoundedCornerShape(14.dp),
            border = BorderStroke(1.dp, Accent.copy(alpha = 0.2f)),
            shadowElevation = 6.dp
        ) {
            Row(Modifier.padding(14.dp), verticalAlignment = Alignment.CenterVertically) {
                Text(message.orEmpty(), color = androidx.compose.ui.graphics.Color.White, fontWeight = FontWeight.Bold, modifier = Modifier.weight(1f))
                Spacer(Modifier.width(8.dp))
            }
        }
    }
}
