// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import {IForwarderRegistry} from "@animoca/ethereum-contracts/contracts/metatx/interfaces/IForwarderRegistry.sol";
import {FusionStorage} from "./../libraries/FusionStorage.sol";
import {BlueprintBase} from "./../base/BlueprintBase.sol";

contract BlueprintFacet1 is BlueprintBase {
    using FusionStorage for FusionStorage.Layout;

    uint256 private constant _CAR_TYPE_MASK = 0xfffffff80000fff000000fffffff000000000000000000000fffffff00000000;

    constructor(
        address cars,
        address revv,
        address cata,
        IForwarderRegistry forwarderRegistry
    ) BlueprintBase(cars, revv, cata, forwarderRegistry) {}

    // solhint-disable-next-line func-name-mixedcase
    function fuse_NAME1(uint256 id) external {
        _fuseOne(
            57910179610855898324494532775552547395017963456962744041009983425274905100288,
            57910179610855898324494532781392852826649382977650253965008245201603429138432,
            id,
            150 ether,
            1 ether
        );
    }

    // solhint-disable-next-line func-name-mixedcase
    function fuse_NAME2(uint256 id) external {
        _fuseOne(
            57910179610855898424928160541739439616390594228285406698647671381124387438592,
            57910179610855898424928160547579745048022013748972916622645932594502958055424,
            id,
            150 ether,
            1 ether
        );
    }

    // solhint-disable-next-line func-name-mixedcase
    function fuse_NAME3(uint256 id) external {
        _fuseOne(
            57910179610855899830998949268355930715607425026802683905575294318767838855168,
            57910179610855899830998949274196236147238844547490193829573552435921665654784,
            id,
            150 ether,
            1 ether
        );
    }

    // solhint-disable-next-line func-name-mixedcase
    function fuse_NAME4(uint256 id) external {
        _fuseOne(
            57910179610855900534034343631664176265215840426061322509039106069064541274112,
            57910179610855900534034343637504481696847259946748832433037362497368507809792,
            id,
            150 ether,
            1 ether
        );
    }

    // solhint-disable-next-line func-name-mixedcase
    function fuse_NAME5(uint256 id) external {
        _fuseOne(
            57910179610855898525361788307926331837763224999608069356285358774023916355584,
            57910179610855898525361788313766637269394644520295579280283620550352440393728,
            id,
            150 ether,
            1 ether
        );
    }

    // solhint-disable-next-line func-name-mixedcase
    function fuse_NAME6(uint256 id) external {
        _fuseOne(
            57910179610855905053547593110074326226984225135581142102735021016624104734720,
            57910179610855905053547593115914631212125312154057295114828416127251353960448,
            id,
            150 ether,
            1 ether
        );
    }

    // solhint-disable-next-line func-name-mixedcase
    function fuse_NAME7(uint256 id) external {
        _fuseOne(
            57910179610855905957450243005756356219337902077485106021474207552719864987648,
            57910179610855905957450243011596661204478989095961259033567600411547300528128,
            id,
            150 ether,
            1 ether
        );
    }

    // solhint-disable-next-line func-name-mixedcase
    function fuse_NAME8(uint256 id1, uint256 id2) external {
        _fuseTwo(
            57910179610855907564388287264746631761299994418647708543677205839112327659520,
            57910179610855907564388287270586936746441081437123861555770594475815112540160,
            id1,
            id2,
            150 ether,
            1 ether
        );
    }

    // solhint-disable-next-line func-name-mixedcase
    function fuse_NAME9(uint256 id1, uint256 id2) external {
        _fuseTwo(
            57910179610855907865689170563307308425417886732615696516590268017810914410496,
            57910179610855907865689170569147613410558973751091849528683656091563745869824,
            id1,
            id2,
            150 ether,
            1 ether
        );
    }

    // solhint-disable-next-line func-name-mixedcase
    function fuse_NAME10(uint256 id1, uint256 id2) external {
        _fuseTwo(
            57910179610855907966122798329494200646790517503938359174227955410710443327488,
            57910179610855907966122798335334505631931604522414512186321343484463274786816,
            id1,
            id2,
            150 ether,
            1 ether
        );
    }

    // solhint-disable-next-line func-name-mixedcase
    function fuse_NAME11(uint256 id1, uint256 id2) external {
        _fuseTwo(
            57910179610855908166990053861867985089535779046583684489503330196509501161472,
            57910179610855908166990053867708290074676866065059837501596717988787355910144,
            id1,
            id2,
            150 ether,
            1 ether
        );
    }

    function _fuseOne(
        uint256 carInputMatchValue,
        uint256 carOutputBaseId,
        uint256 id,
        uint256 revvAmount,
        uint256 cataAmount
    ) internal {
        address sender = _msgSender();
        FusionStorage.enforceIsValidCar(id, _CAR_TYPE_MASK, carInputMatchValue);
        FusionStorage.consumeREVV(_revv, sender, revvAmount);
        FusionStorage.consumeCATA(_cata, sender, cataAmount);
        FusionStorage.Layout storage s = FusionStorage.layout();
        s.consumeCar(_cars, sender, id);
        s.createCar(_cars, sender, carOutputBaseId);
    }

    function _fuseTwo(
        uint256 carInputMatchValue,
        uint256 carOutputBaseId,
        uint256 id1,
        uint256 id2,
        uint256 revvAmount,
        uint256 cataAmount
    ) internal {
        address sender = _msgSender();
        FusionStorage.enforceIsValidCar(id1, _CAR_TYPE_MASK, carInputMatchValue);
        FusionStorage.enforceIsValidCar(id2, _CAR_TYPE_MASK, carInputMatchValue);
        FusionStorage.consumeREVV(_revv, sender, revvAmount);
        FusionStorage.consumeCATA(_cata, sender, cataAmount);
        uint256[] memory ids = new uint256[](2);
        ids[0] = id1;
        ids[1] = id2;
        FusionStorage.Layout storage s = FusionStorage.layout();
        s.batchConsumeCars(_cars, sender, ids);
        s.createCar(_cars, sender, carOutputBaseId);
    }
}
