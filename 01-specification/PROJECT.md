# Project description

This software is a ruby-on-rails application that runs inside dom0 and manages the domU on Xen local host (domUs).

### [53e96a89-ded0-4e3d-9bb8-dacae3ea776c] domUs statuses

- `<not existing>` not really a status
- `idle`
- `running`

### [05bcfcce-90bc-4e3e-a874-1e6f2428a578] domUs transitions

- creation: `<not existing>` -> `idle`
- start: `idle` -> `running`
- stop: `running` -> `idle`
- destroy: `idle` -> `<not existing>`

## Features

  - [c2e3e162-18e5-4328-a17f-7e5d19a36177] The software supports user login.
  - [da2fad86-1fbe-49b2-ae4d-b759a1a31e8b] Login session expires automatically after 60 minutes of inactivity.
  - [d2604c72-b9d8-4d16-af3c-7760247da3bc] Allows to create new domUs, destroy idle domUs
  - [e15ed7bb-da0c-41c1-b2b1-6525ac04d32c] Allows to start idle domUs, stop running domUs, monitor all domUs
  - [4853e803-3e7e-4b25-9b67-458076553892] Allows to modify on idle domUs a fixed subset properties: CPU count (1,2,3,4), memory (min 512M, max 128G), disk (min 4G, max 1000G), and network configuration (one nic max allowed, nic type NAT/HOST ONLY/BRIDGED). This is a demo application, not expecting to suppor all Xen configurations.
  - domUs listing allows:
    - [67f7554f-368b-4254-944e-0db3ea4c496d] see list of all registered domUs with config details
    - [20639907-1e4e-4c9c-8572-d2f37b1207fc] see list of running domUs along with config detail and actual resources usage

## Users and login

  - [4ae7a66a-acbe-41d8-bcbd-2bb5f869af07] There is a builtin user called 'root'.
  - [913b9865-c8a9-4b1e-bd99-a7426b9b35f6] Default password for 'root' is 'root'.
  - [47146764-0f3f-4fa8-8e74-9174d6f83ea6] The application has an administration area for managing users.
  - [d72291e7-ec67-4805-8f95-f26e464f12d7] Only admin role can access administration area.
  - [518937e4-7421-48e6-9a0d-cba7dd7e36c9] 'root' is admin role.
  - [6e6d0a94-5095-4741-a6d1-1f5121a93b97] Users can be created/destroyed/modified.
  - [08dc5b14-3fb0-4271-b297-03fc2d0ba7c5] Application users are independent of dom0 system users.
  - [1a1e2d5c-1272-4d24-9ac0-035b1bdc8ac6] Authentication is password-based
  - [0785be37-afda-46ba-a2f0-133ee4a61723] Every user must have a role assigned.


## Roles and entitlements

  - [868ddd57-47e5-49d3-b685-a60352aa288e] Roles are hardcoded in the application and not user-configurable.
  - [94db1afa-53d3-401a-b848-e61d32b7689c] Entitlemens are hardcoded in the application and not user-configurable.
  - [b6f04691-e95a-42fd-a7f0-5019c2a2a576] The association between each role and set of entitlements is hardcoded in the application and not user-configurable.

## Entitlements

  - [062dbfbe-68b4-4d01-8e23-633933634c55] List of grants (domU allowed statuses already described):

    - (CREATOR) create/destroy domU
    - (ACTIVATOR) start/stop domU
    - (MONITOR) display domU status
    - (EDITOR) modify domU configuration

## Roles

  - [109471c8-0612-40c5-b0e7-fbee14f91a58] List of roles:

    - guest - MONITOR
    - user - MONITOR + ACTIVATOR
    - admin - CREATOR + EDITOR + MONITOR + ACTIVATOR

## Screens

  - [bca5379a-89da-4383-b1d4-a7809cdf5a31] login screen - displayed when user is not logged in (role not defined)
  - [a9f28dee-91c4-4e04-8d2a-89dc25c0b444] domUs listing - default screen when user is logged in (requires role: guest, user, admin). It displays:
    - [82744bc0-3ad8-43f3-a6e9-2413b756bfe1] running domUs list: see list of running domUs along with config detail and actual resources usage
    - [5c31f670-dc74-4c05-bf0f-2e7100919270] configured domUs list: see list of all registered domUs with config details
  - [b94a82c9-6c45-478e-b7d5-8334a367eac1] users administrator screen (requires role: admin)
  - [5cbea95e-a239-4918-bb3c-510caef2e7ed] domU configuration screen (requires role: admin)
