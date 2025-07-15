- name: Run chroot script {{ item }}
  command: chroot {{ CHROOT_DIR }} /bin/bash /tmp/chroot_scripts/{{ item }}
  with_items:
    - A_base.sh
    - B_machine_id.sh
    - C_locale_keyboard.sh
    - D_packages.sh
    - E_user.sh
    - F_lightdm_network.sh
    - G_initramfs.sh
    - H_services.sh
    - I_theme.sh
    - J_autostart.sh
    - K_xsession.sh
    - L_cleanup.sh
  become: true


Whitesur icon theme for mac https://www.gnome-look.org/p/1405756

  #Steps for Mac
  sudo apt install plank -y
  https://www.gnome-look.org/p/1403328 theme shall be in /home/gokul/.themes/


  Set active theme
  xfconf/xfce-perchannel-xml/xsettings.xml

  Content Below
  gokul@cloudify-os-live:~/.config/xfce4$ cat xfconf/xfce-perchannel-xml/xsettings.xml 
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="WhiteSur-Light"/>
    <property name="IconThemeName" type="empty"/>
    <property name="DoubleClickTime" type="empty"/>
    <property name="DoubleClickDistance" type="empty"/>
    <property name="DndDragThreshold" type="empty"/>
    <property name="CursorBlink" type="empty"/>
    <property name="CursorBlinkTime" type="empty"/>
    <property name="SoundThemeName" type="empty"/>
    <property name="EnableEventSounds" type="empty"/>
    <property name="EnableInputFeedbackSounds" type="empty"/>
    <property name="FallbackIconTheme" type="empty"/>
  </property>
  <property name="Xft" type="empty">
    <property name="DPI" type="empty"/>
    <property name="Antialias" type="empty"/>
    <property name="Hinting" type="empty"/>
    <property name="HintStyle" type="empty"/>
    <property name="RGBA" type="empty"/>
    <property name="Lcdfilter" type="empty"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="CanChangeAccels" type="empty"/>
    <property name="ColorPalette" type="empty"/>
    <property name="FontName" type="empty"/>
    <property name="MonospaceFontName" type="empty"/>
    <property name="IconSizes" type="empty"/>
    <property name="KeyThemeName" type="empty"/>
    <property name="ToolbarStyle" type="empty"/>
    <property name="ToolbarIconSize" type="empty"/>
    <property name="MenuImages" type="empty"/>
    <property name="ButtonImages" type="empty"/>
    <property name="MenuBarAccel" type="empty"/>
    <property name="CursorThemeName" type="empty"/>
    <property name="CursorThemeSize" type="empty"/>
    <property name="DecorationLayout" type="empty"/>
    <property name="DialogsUseHeader" type="empty"/>
    <property name="TitlebarMiddleClick" type="empty"/>
  </property>
  <property name="Gdk" type="empty">
    <property name="WindowScalingFactor" type="empty"/>
  </property>
</channel>


