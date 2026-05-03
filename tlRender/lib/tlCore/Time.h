// SPDX-License-Identifier: BSD-3-Clause
// Copyright (c) 2021-2024 Darby Johnston
// All rights reserved.

#pragma once

#include <tlCore/Util.h>

#include <nlohmann/json.hpp>

#include <chrono>
#include <iostream>

namespace tl
{
    //! Time
    namespace time
    {
        //! Sleep for a given time.
        void sleep(const std::chrono::microseconds&);

        //! Sleep up to the given time.
        void sleep(
            const std::chrono::microseconds&,
            const std::chrono::steady_clock::time_point& t0,
            const std::chrono::steady_clock::time_point& t1);

        //! Convert a floating point rate to a rational.
        std::pair<int, int> toRational(double);

        //! \name Keycode
        ///@{

        std::string
        keycodeToString(int id, int type, int prefix, int count, int offset);

        void stringToKeycode(
            const std::string&, int& id, int& type, int& prefix, int& count,
            int& offset);

        ///@}

        //! \name Timecode
        ///@{

        void timecodeToTime(
            uint32_t, int& hour, int& minute, int& second, int& frame);

        uint32_t timeToTimecode(int hour, int minute, int second, int frame);

        std::string timecodeToString(uint32_t);

        void stringToTimecode(const std::string&, uint32_t&);

        ///@}
    } // namespace time
} // namespace tl

#include <tlCore/TimeInline.h>
