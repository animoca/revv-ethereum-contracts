// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import {IForwarderRegistry} from "@animoca/ethereum-contracts/contracts/metatx/interfaces/IForwarderRegistry.sol";
import {FusionStorage} from "./../libraries/FusionStorage.sol";
import {BlueprintBase} from "./../base/BlueprintBase.sol";

contract BlueprintFacet1 is BlueprintBase {
    using FusionStorage for FusionStorage.Layout;

    constructor(address cars, address revv, address cata, IForwarderRegistry forwarderRegistry) BlueprintBase(cars, revv, cata, forwarderRegistry) {}

    // solhint-disable-next-line func-name-mixedcase
    function fuse_Common_Rare_1(uint256 id) external {
        _fuseOne(
            57910179610855898424928160541739439616390594228285406698647671381124387438592,
            57910179610855898424928160547579767348767212279596058158364205242864464035840,
            id,
            300 ether,
            1 ether
        );
    }

    // solhint-disable-next-line func-name-mixedcase
    function fuse_Common_Rare_2(uint256 id) external {
        _fuseOne(
            57910179610855899830998949268355930715607425026802683905575294318767838855168,
            57910179610855899830998949274196258447984043078113335365291825084283171635200,
            id,
            300 ether,
            1 ether
        );
    }

    // solhint-disable-next-line func-name-mixedcase
    function fuse_Common_Rare_3(uint256 id) external {
        _fuseOne(
            57910179610855900534034343631664176265215840426061322509039106069064541274112,
            57910179610855900534034343637504503997592458477371973968755635145730013790208,
            id,
            300 ether,
            1 ether
        );
    }

    // solhint-disable-next-line func-name-mixedcase
    function fuse_Common_Rare_4(uint256 id) external {
        _fuseOne(
            57910179610855898525361788307926331837763224999608069356285358774023916355584,
            57910179610855898525361788313766659570139843050918720816001893198713946374144,
            id,
            300 ether,
            1 ether
        );
    }

    // solhint-disable-next-line func-name-mixedcase
    function fuse_Common_Rare_5(uint256 id) external {
        _fuseOne(
            57910179610855905053547593110074326226984225135581142102735021016624104734720,
            57910179610855905053547593115914653512870510684680436650546688775612859940864,
            id,
            300 ether,
            1 ether
        );
    }

    // solhint-disable-next-line func-name-mixedcase
    function fuse_Common_Rare_6(uint256 id) external {
        _fuseOne(
            57910179610855905957450243005756356219337902077485106021474207552719864987648,
            57910179610855905957450243011596683505224187626584400569285873059908806508544,
            id,
            300 ether,
            1 ether
        );
    }

    // solhint-disable-next-line func-name-mixedcase
    function fuse_Common_Rare_7(uint256 id) external {
        _fuseOne(
            57910179610855907564388287264746631761299994418647708543677205839112327659520,
            57910179610855907564388287270586959047186279967747003091488867124176618520576,
            id,
            300 ether,
            1 ether
        );
    }

    // solhint-disable-next-line func-name-mixedcase
    function fuse_Common_Rare_8(uint256 id) external {
        _fuseOne(
            57910179610855907865689170563307308425417886732615696516590268017810914410496,
            57910179610855907865689170569147635711304172281714991064401928739925251850240,
            id,
            300 ether,
            1 ether
        );
    }

    // solhint-disable-next-line func-name-mixedcase
    function fuse_Common_Rare_9(uint256 id) external {
        _fuseOne(
            57910179610855907966122798329494200646790517503938359174227955410710443327488,
            57910179610855907966122798335334527932676803053037653722039616132824780767232,
            id,
            300 ether,
            1 ether
        );
    }

    // solhint-disable-next-line func-name-mixedcase
    function fuse_Common_Rare_10(uint256 id) external {
        _fuseOne(
            57910179610855908166990053861867985089535779046583684489503330196509501161472,
            57910179610855908166990053867708312375422064595682979037314990637148861890560,
            id,
            300 ether,
            1 ether
        );
    }

    // solhint-disable-next-line func-name-mixedcase
    function fuse_Common_Rare_11(uint256 id1, uint256 id2) external {
        uint256[] memory carInputMatchValues = new uint256[](2);
        carInputMatchValues[0] = 57910179610855907564388287264746631761299994418647708543677205839112327659520;
        carInputMatchValues[1] = 57910179610855907865689170563307308425417886732615696516590268017810914410496;
        uint256[] memory ids = new uint256[](2);
        ids[0] = id1;
        ids[1] = id2;
        _fuseMultiple(carInputMatchValues, 57910179610855916804282041759781043413468310929431967594156082501135328346112, ids, 300 ether, 1 ether);
    }

    // solhint-disable-next-line func-name-mixedcase
    function fuse_Common_Rare_12(uint256 id1, uint256 id2) external {
        uint256[] memory carInputMatchValues = new uint256[](2);
        carInputMatchValues[0] = 57910179610855907966122798329494200646790517503938359174227955410710443327488;
        carInputMatchValues[1] = 57910179610855908166990053861867985089535779046583684489503330196509501161472;
        uint256[] memory ids = new uint256[](2);
        ids[0] = id1;
        ids[1] = id2;
        _fuseMultiple(carInputMatchValues, 57910179610855916904715669525967935634840941700754630251793769894034857263104, ids, 300 ether, 1 ether);
    }

    function _fuseOne(uint256 carInputMatchValue, uint256 carOutputBaseId, uint256 id, uint256 revvAmount, uint256 cataAmount) internal {
        address sender = _msgSender();
        _enforceIsValidCar(id, carInputMatchValue);
        FusionStorage.consumeREVV(_revv, sender, revvAmount);
        FusionStorage.consumeCATA(_cata, sender, cataAmount);
        FusionStorage.Layout storage s = FusionStorage.layout();
        s.consumeCar(_cars, sender, id);
        s.createCar(_cars, sender, carOutputBaseId);
    }

    function _fuseMultiple(
        uint256[] memory carInputMatchValues,
        uint256 carOutputBaseId,
        uint256[] memory ids,
        uint256 revvAmount,
        uint256 cataAmount
    ) internal {
        address sender = _msgSender();
        uint256 length = carInputMatchValues.length;
        for (uint256 i; i < length; ++i) {
            _enforceIsValidCar(ids[i], carInputMatchValues[i]);
        }
        FusionStorage.consumeREVV(_revv, sender, revvAmount);
        FusionStorage.consumeCATA(_cata, sender, cataAmount);
        FusionStorage.Layout storage s = FusionStorage.layout();
        s.batchConsumeCars(_cars, sender, ids);
        s.createCar(_cars, sender, carOutputBaseId);
    }
}
