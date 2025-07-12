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