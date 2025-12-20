import 'package:flutter/material.dart';

import '../../domain/entities/festive_effect.dart';
import '../../domain/entities/interaction_idea.dart';

const mockEffects = <FestiveEffect>[
  FestiveEffect(
    name: 'Aurora Sky',
    description: 'Shader 驱动的极光渐变，可随音乐节奏与时间切换色带。',
    tags: ['shader', 'ambient', 'dynamic color'],
    icon: Icons.auto_awesome,
  ),
  FestiveEffect(
    name: 'Snow Field',
    description: '多层粒子雪花支持大小与速度衰减，营造暴风雪质感。',
    tags: ['particles', 'winter'],
    icon: Icons.ac_unit,
  ),
  FestiveEffect(
    name: 'Glowing Tree',
    description: '圣诞树 LED 路径与节奏绑定，可自由调节色盘与亮度。',
    tags: ['music sync', 'lights'],
    icon: Icons.forest,
  ),
  FestiveEffect(
    name: 'Gift Fireworks',
    description: '礼盒点击触发焰火爆裂，伴随余音与轻微震动反馈。',
    tags: ['burst', 'interaction'],
    icon: Icons.card_giftcard,
  ),
  FestiveEffect(
    name: 'Crystal Particles',
    description: '指尖拖拽生成晶体粒子轨迹，离开屏幕后缓慢消散。',
    tags: ['gesture', 'afterglow'],
    icon: Icons.gesture,
  ),
  FestiveEffect(
    name: 'Candy Cane Rain',
    description: '限定时段触发拐杖糖雨，并伴有铃声提示与光闪。',
    tags: ['timed event', 'sound'],
    icon: Icons.icecream,
  ),
  FestiveEffect(
    name: 'Starry Village',
    description: '远景小镇灯光视差滚动，营造通透的冬夜背景。',
    tags: ['parallax', 'background'],
    icon: Icons.home,
  ),
  FestiveEffect(
    name: 'Frost Transition',
    description: '霜痕遮罩式转场，用于在场景/主题之间优雅切换。',
    tags: ['transition', 'mask'],
    icon: Icons.blur_on,
  ),
  FestiveEffect(
    name: 'Ribbon Portal',
    description: '长按唤出丝带旋转门，串联不同体验页面。',
    tags: ['long press', 'portal'],
    icon: Icons.all_inclusive,
  ),
  FestiveEffect(
    name: 'Toy Parade',
    description: '玩具巡游的 Rive 动画，与节奏碰撞即可触发特写。',
    tags: ['rive', 'looping'],
    icon: Icons.toys,
  ),
  FestiveEffect(
    name: 'Bell Chime',
    description: '双指合拢触发钟声与震动，同时撒落粒子光点。',
    tags: ['haptics', 'audio'],
    icon: Icons.notifications_active,
  ),
  FestiveEffect(
    name: 'Meteor Shower',
    description: '夜空流星雨，拖尾 Shader 模拟燃烧尾焰。',
    tags: ['night', 'trails'],
    icon: Icons.nordic_walking,
  ),
  FestiveEffect(
    name: 'Magic Dust',
    description: '语音祝福转为彩色文字与光尘，飘散全屏。',
    tags: ['voice', 'text render'],
    icon: Icons.mic,
  ),
  FestiveEffect(
    name: 'Polar Wind',
    description: '陀螺仪与麦克风合成极地风，驱动雪雾方向。',
    tags: ['sensor fusion', 'physics'],
    icon: Icons.air,
  ),
  FestiveEffect(
    name: 'Cookie Baking',
    description: '午夜自动切入烘焙模式，加入热气与香味提示。',
    tags: ['time switch', 'steam'],
    icon: Icons.local_fire_department,
  ),
  FestiveEffect(
    name: 'Midnight Clockwork',
    description: '巨型齿轮钟表旋转，配合心跳式脉冲灯效。',
    tags: ['clock', 'pulse'],
    icon: Icons.watch_later,
  ),
  FestiveEffect(
    name: 'Star Choir',
    description: '星星随合唱音量发光，越靠近越亮。',
    tags: ['audio reactive', 'glow'],
    icon: Icons.music_note,
  ),
  FestiveEffect(
    name: 'Lantern Drift',
    description: '纸灯自底部缓慢漂浮，可交互拖拽改变轨迹。',
    tags: ['ambient', 'cozy'],
    icon: Icons.emoji_objects,
  ),
  FestiveEffect(
    name: 'North Pole Mail',
    description: '北极特快邮件展示祝福，并伴随雪花飘落。',
    tags: ['message', 'sharing'],
    icon: Icons.mail,
  ),
  FestiveEffect(
    name: 'Aurora Trails',
    description: '头部或手部移动生成拖尾光轨，适合舞蹈表演。',
    tags: ['gpu', 'afterimage'],
    icon: Icons.trending_flat,
  ),
];

const mockInteractionIdeas = <InteractionIdea>[
  InteractionIdea('触感走廊', '观众触摸或滑动舞台两侧，驱动光束与投影。'),
  InteractionIdea('设备联动', '摇晃/倾斜设备改变雪花风向，或控制光束方向。'),
  InteractionIdea('社交祝福', '导出 GIF / 短视频分享到社交平台并附祝福。'),
  InteractionIdea('场景联动', '接入温湿度/天气 API 自动切换雪景或晴空。'),
  InteractionIdea('远程点亮', '通过 WebSocket / 蓝牙同步多台设备灯光。'),
];
