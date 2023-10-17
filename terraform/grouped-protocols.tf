variable "group-aave" {
  type        = list(string)
  default     = ["aave"]
}

variable "group-balancer" {
  type        = list(string)
  default     = ["balancer"]
}

variable "group-uniswap" {
  type        = list(string)
  default     = ["uniswap"]
}

variable "group-sushiswap" {
  type        = list(string)
  default     = ["sushiswap"]
}

variable "group-beefy" {
  type        = list(string)
  default     = ["beefy"]
}

variable "group-curve" {
  type        = list(string)
  default     = ["curve"]
}

variable "group-hop" {
  type        = list(string)
  default     = ["hop"]
}

variable "group-ethereum" {
  type        = list(string)
  default     = ["mstable", "iron-bank", "polygon", "bancor", "arpa", "blur", "tornadocash", "stakefish", "swell", "cowswap", "lido", "chainlink", "olympusdao" , "wepiggy", "compound", "ribbon", "looksrare", "convex", "makerdao", "maplefinance"]
}

variable "group-optimism" {
  type        = list(string)
  default     = ["aelin", "trader-joe", "aura", "velodrome", "beethovenx", "thales", "extra-finance", "ethos"]
}

variable "group-arbitrum" {
  type        = list(string)
  default     = ["radiant", "gmx", "gains", "camelot", "solidlizard", "swapfish"]
}

variable "group-base" {
  type        = list(string)
  default     = ["alienbase", "sonne", "pika", "moonwell", "autoearn", "baseswap", "aerodrome"]
}

variable "group-polygon" {
  type        = list(string)
  default     = ["metavault", "sandbox", "adamant", "pooltogether", "tokemak", "set", "quickswap", "polycat", "dinoswap", "dfyn", "idex", "kyberswap", "apeswap", "dodo"]
}

variable "group-qidao" {
  type        = list(string)
  default     = ["qidao"]
}

variable "group-polygon-zkevm" {
  type        = list(string)
  default     = ["ovix", "stargate"]
}

module "grouped-aave" {
  source = "./modules/grouped-protocols"

  base-image = var.base-image
  group-name = "aave"
  companies = var.group-aave
}

module "grouped-balancer" {
  source = "./modules/grouped-protocols"

  base-image = var.base-image
  group-name = "balancer"
  companies = var.group-balancer
}

module "grouped-uniswap" {
  source = "./modules/grouped-protocols"

  base-image = var.base-image
  group-name = "uniswap"
  companies = var.group-uniswap
}

module "grouped-sushiwap" {
  source = "./modules/grouped-protocols"

  base-image = var.base-image
  group-name = "sushiswap"
  companies = var.group-sushiswap
}

module "grouped-curve" {
  source = "./modules/grouped-protocols"

  base-image = var.base-image
  group-name = "curve"
  companies = var.group-curve
}

module "grouped-beefy" {
  source = "./modules/grouped-protocols"

  base-image = var.base-image
  group-name = "beefy"
  companies = var.group-beefy
}

module "grouped-hop" {
  source = "./modules/grouped-protocols"

  base-image = var.base-image
  group-name = "hop"
  companies = var.group-hop
}

module "grouped-ethereum" {
  source = "./modules/grouped-protocols"

  base-image = var.base-image
  group-name = "ethereum"
  companies = var.group-ethereum
}

module "grouped-optimism" {
  source = "./modules/grouped-protocols"

  base-image = var.base-image
  group-name = "optimism"
  companies = var.group-optimism
}

module "grouped-arbitrum" {
  source = "./modules/grouped-protocols"

  base-image = var.base-image
  group-name = "arbitrum"
  companies = var.group-arbitrum
}

module "grouped-polygon" {
  source = "./modules/grouped-protocols"

  base-image = var.base-image
  group-name = "polygon"
  companies = var.group-polygon
}

module "grouped-base" {
  source = "./modules/grouped-protocols"

  base-image = var.base-image
  group-name = "base"
  companies = var.group-base
}

module "grouped-polygon-zkevm" {
  source = "./modules/grouped-protocols"

  base-image = var.base-image
  group-name = "polygon-zkevm"
  companies = var.group-polygon-zkevm
}

module "grouped-polygon-qidao" {
  source = "./modules/grouped-protocols"

  base-image = var.base-image
  group-name = "qidao"
  companies = var.group-qidao
}