package com.araciyok.nativeapp.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.ChatBubbleOutline
import androidx.compose.material.icons.outlined.Send
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Divider
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.araciyok.nativeapp.data.DemoViewModel
import com.araciyok.nativeapp.ui.components.AppCard
import com.araciyok.nativeapp.ui.components.EmptyState
import com.araciyok.nativeapp.ui.components.MessageBubble
import com.araciyok.nativeapp.ui.components.ScreenList
import com.araciyok.nativeapp.ui.components.SecondaryAction
import com.araciyok.nativeapp.ui.components.SectionHeader
import com.araciyok.nativeapp.ui.components.StatusChip
import com.araciyok.nativeapp.ui.theme.Accent
import com.araciyok.nativeapp.ui.theme.Border
import com.araciyok.nativeapp.ui.theme.Navy
import com.araciyok.nativeapp.ui.theme.Surface
import com.araciyok.nativeapp.ui.theme.TextMuted

@Composable
fun MessagesScreen(vm: DemoViewModel) {
    ScreenList {
        SectionHeader("Mesajlar", "Sadece kabul edilmiş işler için konuşma açılır.")
        val conversations = vm.conversations()
        if (conversations.isEmpty()) {
            EmptyState("Henüz mesaj yok", "Mesajlaşma teklif kabul edildikten sonra açılır.")
        } else {
            conversations.forEach { user ->
                val unread = vm.messages.count { it.fromUserId == user.id && it.toUserId == vm.currentUserId && it.unread }
                AppCard(onClick = {
                    vm.selectedChatUserId = user.id
                    vm.markConversationRead(user.id)
                }) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Outlined.ChatBubbleOutline, contentDescription = null, tint = Accent, modifier = Modifier.size(30.dp))
                        Spacer(Modifier.width(12.dp))
                        Column(Modifier.weight(1f)) {
                            Text(user.name, color = Navy, fontWeight = FontWeight.Black, fontSize = 17.sp)
                            Text("Kabul edilmiş iş konuşması", color = TextMuted)
                        }
                        if (unread > 0) StatusChip(unread.toString(), Accent)
                    }
                }
            }
        }
    }
}

@Composable
fun ChatScreen(vm: DemoViewModel) {
    val other = vm.selectedChatUserId?.let { vm.user(it) } ?: return
    var text by remember { mutableStateOf("") }
    val messages = vm.messages.filter {
        (it.fromUserId == vm.currentUserId && it.toUserId == other.id) ||
            (it.fromUserId == other.id && it.toUserId == vm.currentUserId)
    }

    LaunchedEffect(other.id) {
        vm.markConversationRead(other.id)
    }

    Column(
        Modifier
            .fillMaxSize()
            .padding(horizontal = 16.dp, vertical = 12.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        AppCard {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Outlined.ChatBubbleOutline, contentDescription = null, tint = Accent)
                Spacer(Modifier.width(10.dp))
                Column(Modifier.weight(1f)) {
                    Text(other.name, color = Navy, fontWeight = FontWeight.Black, fontSize = 20.sp)
                    Text("Mesajlaşma sadece eşleşme sonrası açıktır.", color = TextMuted)
                }
            }
        }
        LazyColumn(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(messages, key = { it.id }) { msg ->
                MessageBubble(text = msg.text, mine = msg.fromUserId == vm.currentUserId)
            }
        }
        Divider(color = Border)
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalAlignment = Alignment.CenterVertically) {
            OutlinedTextField(
                value = text,
                onValueChange = { text = it },
                label = { Text("Mesaj yaz") },
                modifier = Modifier.weight(1f),
                shape = RoundedCornerShape(14.dp)
            )
            Button(
                onClick = {
                    if (text.isNotBlank()) {
                        vm.sendMessage(text.trim())
                        text = ""
                    }
                },
                shape = RoundedCornerShape(14.dp),
                colors = ButtonDefaults.buttonColors(containerColor = Accent)
            ) {
                Icon(Icons.Outlined.Send, contentDescription = "Gönder")
            }
        }
        SecondaryAction("Geri Dön") { vm.selectedChatUserId = null }
    }
}
