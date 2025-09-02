local file = require('@lib/file')
local merge = require('@utils/merge')
local project = require('@lib/project')

local name = project.project.name
local default = {
	owner = { group = 0 },

	environments = {
		{
			label = 'release',
			targetAccess = 'public',
			branches = { 'main' },
		},
		{
			label = 'next',
			targetAccess = 'private',
			branches = { 'next' },
			targetOverrides = {
				places = {
					start = {
						configuration = {
							name = `{name} [next]`,
						},
					},
					match = {
						configuration = {
							name = `{name} [next]`,
						},
					},
				},
			},
		},
	},
	state = {
		remote = {
			bucket = 'game-mantle-states',
			key = 'game',
			region = {
				custom = {
					name = 'ENAM',
					endpoint = 'https://dc88f586de4d2c1eb08099d9e049613e.r2.cloudflarestorage.com',
				},
			},
		},
	},

	target = {
		experience = {
			spatialVoice = { enabled = true },
			configuration = {
				genre = 'all',

				enableStudioAccessToApis = true,
				allowThirdPartyTeleports = false,
				allowThirdPartySales = false,

				avatarType = 'playerChoice',
				avatarAnimationType = 'playerChoice',
				avatarCollisionType = 'outerBox',
			},
			places = {
				start = {
					file = 'dist/rojo/lobby.rbxl',
					configuration = {
						name = name,
						serverFill = 'robloxOptimized',
						maxPlayerCount = 50,
						allowCopying = false,
					},
				},
				match = {
					file = 'dist/rojo/match.rbxl',
					configuration = {
						name = name,
						serverFill = 'robloxOptimized',
						maxPlayerCount = 50,
						allowCopying = false,
					},
				},
			},

			assets = { 'assets/images/products/*.png' },
			products = {
				vip = {
					name = 'VIP',
					icon = 'assets/images/products/vip.png',
					price = 499,
				},
			},
		},
	},
}
local manifest = merge(default, file.read_yaml('mantle.yml') or file.read_yaml('mantle.yaml') or {})

--[[
	The main configuration object for Mantle.
	Defines the target resource which Mantle will deploy to and deployment environments.
]]
export type Manifest = {
	--[[
		The owner of the resources that will be created.
		
		| Value         | Description                                                     |
		| ------------- | --------------------------------------------------------------- |
		| `'personal'`  | All resources will be created in the authorizer user's account. |
		| `group: <id>` | All resources will be created in the specified group's account. |
		
		Default: 'personal'
		
		Example:
			owner: personal
			
		Example with group:
			owner:
				group: 5723117
	]]
	owner: Owner?,

	--[[
		Determines which account should make payments when creating resources
		that cost Robux. Note that Mantle will never make purchases unless the
		`--allow-purchases` flag is enabled.
		
		| Value        | Description                                                                                                                                                                                                                                                              |
		| ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
		| `'owner'`    | All payments will come from the balance of the user or group specified by the [`owner`](#owner) property.                                                                                                                                                                |
		| `'personal'` | All payments will come from the balance of the authorized user.                                                                                                                                                                                                          |
		| `'group'`    | All payments will come from the balance of the group specified by the [`owner`](#owner) property. Payments can only be set to `'group'` when the owner is also set to a group because Roblox does not currently allow groups to pay for resources outside of themselves. |
		
		Default: 'owner'
	]]
	payments: Payments?,

	--[[
		Defines how Mantle should manage state files (locally or remotely).
		
		| Value              | Description                                                                                                                                                                                                           |
		| ------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
		| `'local'`          | Mantle will save and load its state to and from a local `.mantle-state.yml` file.                                                                                                                                     |
		| `localKey: <key>`  | Mantle will save and load its state to and from a local file using the provided key with the format `<key>.mantle-state.yml`.                                                                                         |
		| `remote: <config>` | Mantle will save and load its state to and from a remote file stored in a cloud provider. Currently the only supported provider is Amazon S3. For more information, see the [Remote State](/docs/remote-state) guide. |
		
		Default: 'local'
		
		Example:
			state: local
			
		Example with custom key:
			state:
				localKey: pirate-wars
				
		Example with remote S3:
			state:
				remote:
					region: us-west-1
					bucket: my-mantle-states
					key: pirate-wars
	]]
	state: State?,

	--[[
		The list of environments which Mantle can deploy to.
		
		Example:
			environments:
				- label: staging
					branches: [dev, dev/*]
					targetOverrides:
						configuration:
							icon: marketing/beta-game-icon.png
				- label: production
					branches: [main]
					targetAccess: public
	]]
	environments: { Environment },

	--[[
		Defines the target resource which Mantle will deploy to. Currently
		Mantle only supports targeting Experiences, but in the future it will
		support other types like Plugins and Models.
		
		Example:
			target:
				experience: {}
	]]
	target: Target,
}

--[[
	The owner of the resources that will be created.
]]
export type Owner = 'personal' | { group: number }

--[[
	Determines which account should make payments when creating resources that cost Robux.
]]
export type Payments = 'owner' | 'personal' | 'group'

--[[
	An environment configuration that Mantle can deploy to.
]]
export type Environment = {
	--[[
		The label of the environment that is used to identify the environment
		via the `--environment` flag. Must be unique across all environments.
	]]
	label: string,

	--[[
		An array of file globs to match against Git branches. If the
		`--environment` flag is not specified, Mantle will pick the first
		environment which contains a matching file glob for the current Git
		branch. If no environments match, Mantle will exit with a success code.
	]]
	branches: { string }?,

	--[[
		Whether or not to tag the commit with place file versions after
		successful deployments. It is recommended to only enable this on your
		production environment. Tags will be of the format `<label>-v<version>`
		where `<label>` is the label of the place and `<version>` is the place's
		Roblox version.
		
		For example, a start place with Roblox version 23 would have the tag
		`start-v23`.
	]]
	tagCommit: boolean?,

	--[[
		Adds a prefix to the target's name configuration. The implementation is dependent on the
		target's type. For Experience targets, all place names will be updated with the prefix.
		
		| Value                | Description                                                                                                                                                                                                                                                                                                                                |
		| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
		| `'environmentLabel'` | The target name prefix will use the format `[<ENVIRONMENT>] ` where `<ENVIRONMENT>` is the value of the environment's [`label`](#environments--label) property in all caps. For example, if the environment's label was `'dev'` and the target's name was "Made with Mantle", the resulting target name will be "\[DEV] Made with Mantle". |
		| `custom: <prefix>`   | The target name prefix will be the supplied value.                                                                                                                                                                                                                                                                                         |
		
		Example with environment label:
			environments:
				- label: dev
					targetNamePrefix: environmentLabel
				- label: prod
					
		Example with custom prefix:
			environments:
				- label: dev
					targetNamePrefix:
						custom: 'Prefix: '
				- label: prod
	]]
	targetNamePrefix: ('environmentLabel' | { custom: string })?,

	--[[
		Overrides the target's access. The implementation is dependent on the
		target's type. For Experience targets, the
		[`playability`](#target-experience-configuration-playability) property
		will be overridden.
		
		| Value       | Description                                                                               |
		| ----------- | ----------------------------------------------------------------------------------------- |
		| `'public'`  | The target will be accessible to all Roblox users.                                        |
		| `'private'` | The target will only be accessible to the authorized user.                                |
		| `'friends'` | The target will only be accessible to the authorized user and that user's Roblox friends. |
	]]
	targetAccess: string?,

	--[[
		Environment-specific overrides for the target resource definition. This
		will override all configuration, including changes made by the
		[`targetNamePrefix`](#environments--targetnameprefix) and
		[`targetAccess`](#environments--targetaccess) properties.
		
		Override the target configuration. Should match the type of the target
		configuration.
	]]
	targetOverrides: Experience?,
}

--[[
	Defines how Mantle should manage state files (locally or remotely).
]]
export type State = 'local' | { localKey: string } | { remote: StateRemote }

--[[
	Configuration for remote state storage in Amazon S3.
]]
export type StateRemote = {
	--[[
		The AWS region your S3 bucket is located in. If for some reason you need
		to use a region that is not defined, you can supply a custom one:
		
		Example:
			state:
				remote:
					region:
						custom:
							name: region-name
							endpoint: region-endpoint
					bucket: my-mantle-states
					key: pirate-wars
	]]
	region: StateRemoteRegion,

	--[[
		The name of your AWS S3 bucket.
	]]
	bucket: string,

	--[[
		The key to use to store your state file. The file will be named with the format
		`<key>.mantle-state.yml`.
	]]
	key: string,
}

--[[
	Supported AWS regions for remote state storage.
]]
export type StateRemoteRegion =
	{ custom: { name: string, endpoint: string } }
	| 'ap-east-1'
	| 'ap-northeast-1'
	| 'ap-northeast-2'
	| 'ap-northeast-3'
	| 'ap-south-1'
	| 'ap-southeast-1'
	| 'ap-southeast-2'
	| 'ca-central-1'
	| 'eu-central-1'
	| 'eu-west-1'
	| 'eu-west-2'
	| 'eu-west-3'
	| 'eu-north-1'
	| 'eu-south-1'
	| 'me-south-1'
	| 'sa-east-1'
	| 'us-east-1'
	| 'us-east-2'
	| 'us-west-1'
	| 'us-west-2'
	| 'us-gov-east-1'
	| 'us-gov-west-1'
	| 'cn-north-1'
	| 'cn-northwest-1'
	| 'af-south-1'

--[[
	The target resource which Mantle will deploy to.
]]
export type Target = { experience: Experience }

--[[
	Configuration for a Roblox Experience.
]]
export type Experience = {
	--[[
		The Experience's Roblox configuration.
		
		Example:
			target:
				experience:
					configuration:
						genre: naval
						playableDevices: [computer]
						playability: private
						privateServerPrice: 0
						enableStudioAccessToApis: true
						icon: marketing/game-icon.png
						thumbnails:
							- marketing/game-thumbnail-fall-update.png
							- marketing/game-thumbnail-default.png
		
		Note: In order to configure the name and description of an experience, use the
		[`name`](#target-experience-places-label-configuration-name) and
		[`description`](#target-experience-places-label-configuration-description)
		properties of the experience's start place
	]]
	configuration: ExperienceConfiguration?,

	--[[
		A list of social links that will appear on the experience's webpage.
		
		Example:
			target:
				experience:
					socialLinks:
						- title: Follow on Twitter
							url: https://twitter.com/blakemdev
	]]
	socialLinks: { SocialLink }?,

	--[[
		Products that can be purchased within your experience for Robux.
		
		Example:
			target:
				experience:
					products:
						fiftyGold:
							name: 50 Gold
							description: Add 50 gold to your wallet!
							icon: products/50-gold.png
							price: 25
						hundredGold:
							name: 100 Gold
							description: Add 100 gold to your wallet!
							icon: products/100-gold.png
							price: 45
		
		Because Roblox does not offer any way to delete developer products, when a product is "deleted"
		by Mantle, it is updated in the following ways:
		
		1.  Its description is updated to: `Name: <name>\nDescription:\n<description>`
		2.  Its name is updated to `zzz_Deprecated(<date-time>)` where `<date-time>` is the current
			date-time in `YYYY-MM-DD hh::mm::ss.ns` format.
	]]
	products: { [string]: Product }?,

	--[[
		Badges that can be awarded within your experience.
		
		Example:
			target:
				experience:
					badges:
						captureFirstShip:
							name: Capture First Ship!
							description: You captured your first enemy ship!
							icon: badges/capture-first-ship.png
		
		Warning: Each user can create up to 5 badges for free every day. After that, badges cost 100 Robux each. By
		default, Mantle does not have permission to make purchases with Robux, so if you go over your daily
		quota, you will need to use the `--allow-purchases` flag to create them.
		
		Because Roblox does not offer any way to delete badges, when a badge is "deleted" by Mantle, it is
		updated in the following ways:
		
		1.  It is disabled
		2.  Its description is updated to: `Name: <name>\nEnabled: <enabled>\nDescription:\n<description>`
		3.  Its name is updated to `zzz_Deprecated(<date-time>)` where `<date-time>` is the current date-time
			in `YYYY-MM-DD hh::mm::ss.ns` format.
	]]
	badges: { [string]: Badge }?,

	--[[
		Passes that can be purchased within your experience for Robux.
		
		Example:
			target:
				experience:
					passes:
						shipOfTheLine:
							name: Ship of the Line
							description: Get the best ship in the game!
							icon: passes/ship-of-the-line.png
							price: 499
		
		Because Roblox does not offer any way to delete game passes, when a pass is "deleted" by
		Mantle, it is updated in the following ways:
		
		1.  Its description is updated to: `Name: <name>\nPrice: <price>\nDescription:\n<description>`
		2.  Its name is updated to `zzz_Deprecated(<date-time>)` where `<date-time>` is the current date-time
			in `YYYY-MM-DD hh::mm::ss.ns` format.
	]]
	passes: { [string]: Pass }?,

	--[[
		A list of assets to include in your experience.
		
		If set to a string, the value should be a file path or glob to an asset
		or list of assets. The `rbxgameasset` name of each matched file will be
		its file name without the extension. For example,
		`assets/pirate-flag.png` will be given the `rbxgameasset` name
		`pirate-flag` and will be accessible in the experience with
		`rbxgameasset://Images/pirate-flag`.
		
		If set to an object, `file` should be set to a file path (it will not be
		interpreted as a glob), and `name` will be the name of the
		`rbxgameasset`.
		
		Example:
			target:
				experience:
					assets:
						- assets/*
						- file: marketing/icon.png
							name: game-icon
		
		Warning: Roblox provides each user a monthly quota of audio uploads. Mantle will let you know each time it
		uploads an audio asset how many uploads you have left and when your quota will reset.
		
		Each file will be uploaded as the asset type matching its file
		extension. Supported asset types and their file extensions:
		
		| Asset type | File extensions                                 |
		| :--------- | :---------------------------------------------- |
		| Image      | `.bmp`, `.gif`, `.jpeg`, `.jpg`, `.png`, `.tga` |
		| Audio      | `.ogg`, `.mp3`                                  |
	]]
	assets: ({ string } | { file: string, name: string })?,

	--[[
		Spatial voice configuration.
	]]
	spatialVoice: SpatialVoice?,

	--[[
		Notification strings for your experience.
		
		By default, the name of each notification (which is only visible to you in the creator portal) is set
		to the label of the notification config. You can override this by setting the `name` property.
		
		Example:
			target:
				experience:
					notifications:
						customInvitePrompt:
							content: '{displayName} is inviting you to join {experienceName}!'
		
		Example with custom name:
			target:
				experience:
					notifications:
						customInvitePrompt:
							name: Custom Invite Prompt
							content: '{displayName} is inviting you to join {experienceName}!'
	]]
	notifications: { [string]: Notification }?,

	--[[
		The experience's places. There must be at least one place supplied with
		the label `'start'`, which will be used as the start place for the
		experience.
		
		Example:
			target:
				experience:
					places:
						start:
							file: game.rbxlx
							configuration:
								name: Pirate Wars!
								description: |-
									Duke it out on the high seas in your pirate ship!
									
									🍂 Fall update: new cannons, new ship types!
								maxPlayerCount: 10
								serverFill: robloxOptimized
	]]
	places: { [string]: Place }?,

	--[[
		A file path to an image that will be used as the experience's icon.
	]]
	icon: string?,

	--[[
		An array of file paths to images that will be used as the experience's thumbnails. The order
		used here will be the order they appear on the Roblox webpage.
	]]
	thumbnails: { string }?,
}

--[[
	Spatial voice configuration.
]]
export type SpatialVoice = {
	--[[
		Whether or not spatial voice is enabled for the experience.
	]]
	enabled: boolean,
}

--[[
	Notification string configuration.
]]
export type Notification = {
	--[[
		The display name of the notification string on the Roblox website.
	]]
	name: string?,

	--[[
		The content of the notification string.
		Must include `{experienceName}` placeholder and may include `{displayName}` placeholder once.
	]]
	content: string,
}

--[[
	Social link configuration.
]]
export type SocialLink = {
	--[[
		The display name of the social link on the Roblox website.
	]]
	title: string,

	--[[
		The URL of the social link. Must be one of the Roblox supported social link types.
	]]
	url: string,
}

--[[
	Developer product configuration.
]]
export type Product = {
	--[[
		The display name of the developer product on the Roblox website and in the experience.
	]]
	name: string,

	--[[
		The description of the developer product on the Roblox website and in the experience.
		Default: ''
	]]
	description: string?,

	--[[
		A file path to an image to use as the product's icon on the Roblox website and in the
		experience.
	]]
	icon: string?,

	--[[
		The price of the developer product in Robux.
	]]
	price: number,
}

--[[
	Game pass configuration.
]]
export type Pass = {
	--[[
		A file path to an image to use as the pass's icon on the Roblox website and in the
		experience.
	]]
	icon: string,

	--[[
		The display name of the game pass on the Roblox website and in the experience.
	]]
	name: string,

	--[[
		The description of the game pass on the Roblox website and in the experience.
		Default: ''
	]]
	description: string?,

	--[[
		The price of the game pass in Robux. If not specified, the game pass will be off-sale.
	]]
	price: number,
}

--[[
	Badge configuration.
]]
export type Badge = {
	--[[
		A file path to an image to use as the badge's icon on the Roblox website and in the
		experience.
	]]
	icon: string,

	--[[
		The display name of the badge on the Roblox website and in the experience.
	]]
	name: string,

	--[[
		The description of the badge on the Roblox website and in the experience.
		Default: ''
	]]
	description: string?,
}

--[[
	Place configuration.
]]
export type Place = {
	--[[
		A place's Roblox configuration.
	]]
	configuration: PlaceConfiguration?,
}

--[[
	A place's Roblox configuration.
]]
export type PlaceConfiguration = {
	--[[
		The display name of the place on the Roblox website and in-game. If the
		place is an experience's start place, it will be the experience's
		display name as well.
		Default: 'Untitled Game'
	]]
	name: string?,

	--[[
		The description of the place on the Roblox website and in-game. If the
		place is an experience's start place, it will be the experience's
		description as well.
		Default: 'Created with Mantle'
	]]
	description: string?,

	--[[
		The maximum number of players that can be in a server for the place.
		Default: 50
	]]
	maxPlayerCount: number?,

	--[[
		Determines how Roblox will fill your servers.
		
		| Value                    | Description                                                                          |
		| ------------------------ | ------------------------------------------------------------------------------------ |
		| `'robloxOptimized'`      | Roblox will attempt to automatically leave some space for friends to join.           |
		| `'maximum'`              | Roblox will never leave room for friends to join.                                    |
		| `reservedSlots: <count>` | Roblox will always leave the provided number of slots available for friends to join. |
		
		Default: 'robloxOptimized'
		
		Example:
			target:
				experience:
					places:
						start:
							file: game.rbxlx
							configuration:
								serverFill: maximum
		
		Example with reserved slots:
			target:
				experience:
					places:
						start:
							file: game.rbxlx
							configuration:
								serverFill:
									reservedSlots: 5
	]]
	serverFill: string?,

	--[[
		A file path to an image that will be used as the place's icon.
	]]
	icon: string?,

	--[[
		An array of file paths to images that will be used as the place's thumbnails.
	]]
	thumbnails: { string }?,
}

--[[
	The Experience's Roblox configuration.
]]
export type ExperienceConfiguration = {
	--[[
		The experience's genre.
		Default: 'all'
		
		Supported values: 'all', 'adventure', 'building', 'comedy', 'fighting', 'fps', 'horror', 'medieval', 'military', 'naval', 'rpg', 'sciFi', 'sports', 'townAndCity', 'western'
	]]
	genre: string?,

	--[[
		The devices that the experience can be played on.
		Default: ['computer', 'phone', 'tablet']
		
		Supported values: 'computer', 'phone', 'tablet', 'console', 'vr'
	]]
	playableDevices: { string }?,

	--[[
		Determines who has access to play the experience.
		
		| Value       | Description                                                                                 |
		| ----------- | ------------------------------------------------------------------------------------------- |
		| `'public'`  | The experience will be playable by all Roblox users.                                        |
		| `'private'` | The experience will only be playable by the authorized user.                                |
		| `'friends'` | The experience will only be playable to the authorized user and that user's Roblox friends. |
		
		Default: 'private'
	]]
	playability: string?,

	--[[
		The price for private servers in Robux.
	]]
	privateServerPrice: number?,

	--[[
		Whether or not studio should be able to use Roblox APIs for this place.
		Default: false
	]]
	enableStudioAccessToApis: boolean?,

	--[[
		A file path to an image that will be used as the experience's icon.
	]]
	icon: string?,

	--[[
		An array of file paths to images that will be used as the experience's thumbnails.
	]]
	thumbnails: { string }?,

	--[[
		The type of avatar collision that players can use in this experience.
		Default: 'outerBox'
		
		Supported values: 'outerBox', 'innerBox'
	]]
	avatarCollisionType: string?,

	--[[
		The scale constraints to apply to player avatars in the experience.
		Defaults to Roblox's defaults. Each entry may include a `min`, `max`, or
		both. If one is excluded, the default will be used.
		
		Supported properties: `bodyType`, `head`, `height`, `proportions`, `width`.
		
		Example:
			target:
				experience:
					configuration:
						avatarScaleConstraints:
							height:
								min: 0.95
							width:
								max: 0.9
							proportions:
								min: 30
								max: 50
	]]
	avatarScaleConstraints: AvatarScaleConstraints?,

	--[[
		The asset overrides to apply to player avatars in the experience.
		Defaults to Roblox's defaults.
		
		Supported properties: `face`, `head`, `leftArm`, `leftLeg`, `rightArm`,
		`rightLeg`, `torso`, `tshirt`, `shirt`, `pants`
		
		Example:
			target:
				experience:
					configuration:
						avatarAssetOverrides:
							face: 7699174
							shirt: 5382048848
							pants: 5611120855
	]]
	avatarAssetOverrides: AvatarAssetOverrides?,

	--[[
		Determines whether or not paid access is be enabled, and if it is, how
		much it costs. This should not be enabled when
		[`privateServers`](#target-experience-configuration-privateservers) are
		also enabled as they are incompatible.
		
		| Value            | Description                                                                                      |
		| ---------------- | ------------------------------------------------------------------------------------------------ |
		| `'disabled'`     | Paid access will be disabled.                                                                    |
		| `price: <price>` | Paid access will be enabled and will cost the provided number of Robux. Must be a minimum of 25. |
		
		Default: 'disabled'
		
		Example:
			target:
				experience:
					configuration:
						paidAccess:
							price: 100
	]]
	paidAccess: PaidAccess?,

	--[[
		Legacy property names - these are kept for backward compatibility
		but should use the new property names instead.
	]]
	allowPrivateServers: boolean?,
	allowThirdPartySales: boolean?,
	allowThirdPartyTeleport: boolean?,
	allowVoiceChat: boolean?,
	allowCopying: boolean?,
	allowCloudEditing: boolean?,
	allowStudioAccessToApis: boolean?,
	allowTeamCreate: boolean?,
	allowVideoCapture: boolean?,
	allowGear: boolean?,
	gearGenreSetting: string?,
	gearTypes: { string }?,
}

--[[
	Paid access configuration.
]]
export type PaidAccess = 'disabled' | { price: number }

--[[
	Private servers configuration.
]]
export type PrivateServers = 'disabled' | 'free' | { price: number }

--[[
	Avatar scale constraints configuration.
]]
export type AvatarScaleConstraints = {
	--[[
		The constraints to apply to the height of the avatar.
	]]
	height: AvatarScaleConstraint?,

	--[[
		The constraints to apply to the width of the avatar.
	]]
	width: AvatarScaleConstraint?,

	--[[
		The constraints to apply to the head of the avatar.
	]]
	head: AvatarScaleConstraint?,

	--[[
		The constraints to apply to the body type of the avatar.
	]]
	bodyType: AvatarScaleConstraint?,

	--[[
		The constraints to apply to the proportions of the avatar.
	]]
	proportions: AvatarScaleConstraint?,
}

--[[
	Individual avatar scale constraint.
]]
export type AvatarScaleConstraint = {
	--[[
		The minimum value (float)
	]]
	min: number?,

	--[[
		The maximum value (float)
	]]
	max: number?,
}

--[[
	Avatar asset overrides configuration.
]]
export type AvatarAssetOverrides = {
	--[[
		The asset ID to override the avatar's face.
	]]
	face: number?,

	--[[
		The asset ID to override the avatar's head.
	]]
	head: number?,

	--[[
		The asset ID to override the avatar's torso.
	]]
	torso: number?,

	--[[
		The asset ID to override the avatar's left arm.
	]]
	leftArm: number?,

	--[[
		The asset ID to override the avatar's right arm.
	]]
	rightArm: number?,

	--[[
		The asset ID to override the avatar's left leg.
	]]
	leftLeg: number?,

	--[[
		The asset ID to override the avatar's right leg.
	]]
	rightLeg: number?,

	--[[
		The asset ID to override the avatar's t-shirt.
	]]
	tshirt: number?,

	--[[
		The asset ID to override the avatar's shirt.
	]]
	shirt: number?,

	--[[
		The asset ID to override the avatar's pants.
	]]
	pants: number?,
}

return manifest
