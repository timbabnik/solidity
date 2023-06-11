// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface ERC20 {
    function approve(address spender, uint256 amount) external;
    function transfer(address recipient, uint256 amount) external;
    function transferFrom(address sender, address recipient, uint256 amount) external;
    function balanceOf(address holder) external returns (uint256);
}

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

contract BitSignal {

    uint256 constant BET_LENGTH = 90 days;
    uint256 constant PRICE_THRESHOLD = 1_000_000; // 1 million USD per BTC
    uint256 constant USDC_AMOUNT = 1_000_000e6;
    uint256 constant WBTC_AMOUNT = 1e8;

    ERC20 constant USDC = ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // 6 decimals
    ERC20 constant WBTC = ERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599); // 8 decimals

    AggregatorV3Interface priceFeed = AggregatorV3Interface(0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c); // 8 decimals
    
    bool public wbtcdeposited;
    bool public usdcdeposited;

    address public immutable balaji;
    address public immutable counterparty;

    bool public betinitalized;
    uint256 public starttimestamp;

    constructor(address _balaji, address _counter) {
        balaji = _balaji;
        counterparty = _counter;
    }

    function USDCdeposit() external {
        require(msg.sender == balaji);
        require(!usdcdeposited);

        USDC.transferFrom(balaji, address(this), USDC_AMOUNT);
        usdcdeposited = true;
        if(wbtcdeposited) {
            betinitalized = true;
            starttimestamp = block.timestamp;
        }
    }

    function WBTCdeposit() external {
        require(msg.sender == counterparty);
        require(!wbtcdeposited);

        WBTC.transferFrom(counterparty, address(this), WBTC_AMOUNT);
        wbtcdeposited = true;
        if(usdcdeposited) {
            betinitalized = true;
            starttimestamp = block.timestamp;
        }
    }
    
    function cancel() external {
        require(!betinitalized);
        require(msg.sender == balaji || msg.sender == counterparty);

        if (usdcdeposited) {
            USDC.transfer(balaji, USDC.balanceOf(address(this)));
            usdcdeposited = false;
        }

        if (wbtcdeposited) {
            WBTC.transfer(counterparty, WBTC.balanceOf(address(this)));
            wbtcdeposited = false;
        }
    }

    function settle() external {
        require(betinitalized);
        require(block.timestamp > starttimestamp + BET_LENGTH);

        uint256 price = priceFeedTwo() / 10**priceFeed.decimals();

        address winner;
        if(price >= PRICE_THRESHOLD) {
            winner = balaji;
        } else {
            winner = counterparty;
        }

        USDC.transfer(winner, USDC.balanceOf(address(this)));
        WBTC.transfer(winner, WBTC.balanceOf(address(this)));
    }

    function priceFeedTwo() view public returns(uint256) {
        (,int price,,,) = priceFeed.latestRoundData();
        return uint256(price);
    }

}